//
//  ReaderController.m
//  CardCheck
//
//  Created by itnesPro on 1/5/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "ReaderController.h"

#import "AudioJack.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


#define MAX_CONTROL_COUNTER 10


@interface ReaderController()

@property (nonatomic) BOOL resultReady;
@property (nonatomic, strong) ACRResult *result;

@property (nonatomic) BOOL customIDReady;
@property (nonatomic) BOOL deviceIDReady;

@property (nonatomic) BOOL plugged;
@property (nonatomic, strong) CardReader *cardReader;
@property (nonatomic, strong) ACRAudioJackReader *reader;
@property (nonatomic, strong) NSCondition *responseCondition;

@property (nonatomic) NSUInteger controlCounter;
@property (nonatomic, strong) NSTimer *controlTimer;

@end

@implementation ReaderController

#pragma mark - Init

+ (instancetype)sharedInstance
{
    static ReaderController *RDRController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RDRController = [[self alloc] init];
    });
    return RDRController;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        self.plugged = NO;
        self.resultReady = NO;
        self.customIDReady = NO;
        self.deviceIDReady = NO;
        self.cardReader = [CardReader sharedInstance];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

#pragma mark - Accessors

- (BOOL)isStaging {
    return [[MandatoryData sharedInstance] stageMode];
}

- (void)setDelegate:(id<ReaderControllerDelegate>)delegate
{
    _delegate = delegate;
    if (_delegate) {
        [self didUpdateReader];
    }
    
    [self startIfNeeded];
}

- (void)setPlugged:(BOOL)plugged
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    [self onInfo: [NSString stringWithFormat:@"%@, %@", CURRENT_METHOD, plugged?@"Plugged":@"Un-Plugged"]];
    
    [self.reader setMute: !plugged];
    
    [self.cardReader setPlugged: plugged];
    
    [self tryRequestPrimaryDataIdNeeded: YES];
    
    if (self.pluggedHandler) {
        self.pluggedHandler(self.cardReader);
    }
    
    [self didUpdateReader];
}

#pragma mark - Setup methods

- (void)startIfNeeded
{
    [self onInfo: CURRENT_METHOD];
    
    if (self.reader) return;
    
    self.responseCondition = [[NSCondition alloc] init];
    
    self.reader = [[ACRAudioJackReader alloc] initWithMute: YES];
    [self.reader setDelegate: self];
    
    [self setPlugged: AJDIsReaderPlugged()];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(routeChange:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: nil];
}

- (void)resetReaderController
{
    [self onInfo: CURRENT_METHOD];
    
    [self.cardReader setTrackData: nil];
    [self didUpdateState: ReaderStatePreparing];
    
    __weak ReaderController *weakSelf = self;
    [self.reader resetWithCompletion:^{
        [weakSelf setupControlTimer];
    }];
}

- (void)setupControlTimer
{
    [self onInfo: CURRENT_METHOD];
    
    __weak ReaderController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf didUpdateState: ReaderStateReady];
        
        if (weakSelf.controlTimer) {
            [weakSelf.controlTimer invalidate];
            weakSelf.controlTimer = nil;
        }
        
        weakSelf.controlCounter = 0;
        weakSelf.controlTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self
                                                               selector: @selector(checkControlTimer) userInfo: nil repeats: YES];
    });
}

- (void)checkControlTimer
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    [self onInfo: CURRENT_METHOD];
    
    if (nil == self.controlTimer) return;
    
    self.controlCounter++;
    
    if ([self.delegate respondsToSelector:@selector(readerController:didUpdateWithCounter:)])
    {
        [self.delegate readerController: self didUpdateWithCounter: (MAX_CONTROL_COUNTER - self.controlCounter)];
    }
    else {
        XT_LOG_NOT_IMPLEMENTED;
    }
    
    if (self.controlCounter >= MAX_CONTROL_COUNTER) {
        [self invalidateControlTimer];
        [self resetReaderController];
    }
}

- (void)invalidateControlTimer
{
    [self onInfo: CURRENT_METHOD];
    
    __weak ReaderController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (nil == weakSelf.controlTimer) return;
        
        weakSelf.controlCounter = 0;
        
        [weakSelf.controlTimer invalidate];
        weakSelf.controlTimer = nil;
    });
}

- (void)startStageMode
{
    [[MandatoryData sharedInstance] setStageMode: YES];
    [[MandatoryData sharedInstance] save];
}

- (void)startDemoMode
{
    [self.cardReader setupDemoReaderIfNeeded];
    
    if (self.pluggedHandler) {
        self.pluggedHandler(self.cardReader);
    }
    
    [self didUpdateReader];
}

- (void)generateDemoTrack
{
    [self invalidateControlTimer];
    [self didReceiveTrackData: [TrackData demoTrack]];
}

#pragma mark - Working methods

- (void)tryRequestPrimaryDataIdNeeded:(BOOL)shouldReset
{
    [self onInfo: CURRENT_METHOD];
    
    if ([self.cardReader isReady]) {
        [self didUpdateReader];
    }
    else if (self.cardReader.isPlugged) {
        if (shouldReset) {
            __weak ReaderController *weakSelf = self;
            [self.reader resetWithCompletion:^{
                [weakSelf requestPrimaryData];
            }];
        }
        else {
            [self requestPrimaryData];
        }
    }
}

- (void)requestPrimaryData
{
    [self onInfo: CURRENT_METHOD];
    
    if (self.cardReader.customID == nil) {
        [self requestCustomID];
    }
    else if (self.cardReader.deviceID == nil) {
        [self requestDeviceID];
    }
    else {
        [self didUpdateReader];
    }
}

- (void)requestCustomID
{
    [self onInfo: CURRENT_METHOD];
    
    // Init
    NSError *error = nil;
    self.resultReady = NO;
    self.customIDReady = NO;
    
    if (NO == [self.reader getCustomId])  {
        error = [self completionError: [self currentClass]
                            andReason: @"%@ The request cannot be queued", CURRENT_METHOD];
    }
    else {
        [self.responseCondition lock];
        
        // Wait for the custom ID.
        while ( (NO == self.customIDReady)  && (NO == self.resultReady) ) {
            if (NO == [self.responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
                break;
            }
        }
        
        // Check
        if (NO == self.customIDReady )
        {
            if (self.resultReady) {
                error = [self completionError: [self currentClass]
                                    andReason: @"%@ resultCode = %ui", CURRENT_METHOD, self.result.errorCode];
            }
            else {
                error = [self completionError: [self currentClass]
                                    andReason: @"%@ Timeout", CURRENT_METHOD];
            }
        }
        
        // Complete
        self.customIDReady = NO;
        self.resultReady = NO;
        
        [self.responseCondition unlock];
    }
    
    if (error) {
        [self onFailure: error];
        [self tryRequestPrimaryDataIdNeeded: YES];
    }
    else {
        [self requestPrimaryData];
    }
}

- (void)requestDeviceID
{
    [self onInfo: CURRENT_METHOD];
    
    // Init
    NSError *error = nil;
    self.resultReady = NO;
    self.deviceIDReady = NO;
    
    if (NO == [self.reader getDeviceId])  {
        error = [self completionError: [self currentClass]
                            andReason: @"%@ The request cannot be queued", CURRENT_METHOD];
    }
    else {
        [self.responseCondition lock];
        
        // Wait for the custom ID.
        while ( (NO == self.deviceIDReady)  && (NO == self.resultReady) ) {
            if (NO == [self.responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
                break;
            }
        }
        
        // Check
        if (NO == self.deviceIDReady )
        {
            if (self.resultReady) {
                error = [self completionError: [self currentClass]
                                    andReason: @"%@ resultCode = %ui", CURRENT_METHOD, self.result.errorCode];
            }
            else {
                error = [self completionError: [self currentClass]
                                    andReason: @"%@ Timeout", CURRENT_METHOD];
            }
        }
        
        // Complete
        self.deviceIDReady = NO;
        self.resultReady = NO;
        
        [self.responseCondition unlock];
    }
    
    if (error) {
        [self onFailure: error];
        [self tryRequestPrimaryDataIdNeeded: YES];
    }
    else {
        [self requestPrimaryData];
    }
}

#pragma mark - Delegates

- (void)didUpdateReader
{
    __weak ReaderController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(readerController:didUpdateWithReader:)])
        {
            [weakSelf.delegate readerController: weakSelf didUpdateWithReader: weakSelf.cardReader];
        }
        else {
            XT_LOG_NOT_IMPLEMENTED;
        }
    });
}

- (void)didUpdateState:(ReaderState)state
{
    __weak ReaderController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(readerController:didUpdateWithState:)])
        {
            [weakSelf.delegate readerController: weakSelf didUpdateWithState: state];
        }
        else {
            XT_LOG_NOT_IMPLEMENTED;
        }
    });
}

- (void)didReceiveTrackData:(TrackData *)data
{
    __weak ReaderController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(readerController:didReceiveTrackData:)])
        {
            [weakSelf.delegate readerController: weakSelf didReceiveTrackData: data];
        }
        else {
            XT_LOG_NOT_IMPLEMENTED;
        }
    });
}

#pragma mark - Audio Jack Reader

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result
{
    [self.responseCondition lock];
    
    self.result = result;
    self.resultReady = YES;
    
    [self.responseCondition signal];
    [self.responseCondition unlock];
}

- (void)readerDidNotifyTrackData:(ACRAudioJackReader *)reader
{
    [self onInfo: CURRENT_METHOD];
    
    [self didUpdateState: ReaderStateGettingData];
}

- (void)reader:(ACRAudioJackReader *)reader didSendTrackData:(ACRTrackData *)trackData
{
    [self onInfo: CURRENT_METHOD];
    
    //1
    [self invalidateControlTimer];
    
    //2
    ACRAesTrackData *aesTrackData = (ACRAesTrackData *) trackData;

    TrackData *cTrackData = [TrackData emptyTrack];
    [cTrackData setupWithAesTrackData: aesTrackData];
    
    //3
    [self didReceiveTrackData: cTrackData];
}

- (void)reader:(ACRAudioJackReader *)reader didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length
{
    [self onInfo: CURRENT_METHOD];
}

- (void)reader:(ACRAudioJackReader *)reader didSendCustomId:(const uint8_t *)customId length:(NSUInteger)length
{
    [self onInfo: CURRENT_METHOD];
    
    [self.responseCondition lock];
    
    self.customIDReady = YES;
    NSData *data = [NSData dataWithBytes: customId length: length];
    [self.cardReader setupWithCustomID: [HexCvtr hexFromData: data]];
    
    [self.responseCondition signal];
    [self.responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length
{
    [self onInfo: CURRENT_METHOD];
    
    [self.responseCondition lock];
    
    self.deviceIDReady = YES;
    NSData *data = [NSData dataWithBytes: deviceId length: length];
    [self.cardReader setupWithDeviceID: [HexCvtr hexFromData: data]];
    
    [self.responseCondition signal];
    [self.responseCondition unlock];
}

#pragma mark - Debugging

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

#pragma mark - Private Functions

static BOOL AJDIsReaderPlugged() {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* input in [route inputs])
    {
        if ([[input portType] isEqualToString:AVAudioSessionPortHeadsetMic])
        {
            for (AVAudioSessionPortDescription* output in [route outputs])
            {
                if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones])
                    return YES;
            }
            break;
        }
    }
    return NO;
}

- (void)routeChange:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey: AVAudioSessionRouteChangeReasonKey] integerValue];
    
    __weak ReaderController *weakSelf = self;
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setPlugged: AJDIsReaderPlugged()];
            });
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setPlugged: AJDIsReaderPlugged()];
            });
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            // called at start - also when other audio wants to play
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setPlugged: AJDIsReaderPlugged()];
            });
        }
            break;
            
        default:
            break;
    }
}

@end
