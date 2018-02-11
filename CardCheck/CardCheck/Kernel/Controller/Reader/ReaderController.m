//
//  ReaderController.m
//  CardCheck
//
//  Created by itnesPro on 1/5/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "ReaderController.h"

#import "AudioJack.h"

#import <AudioToolbox/AudioSession.h>
#import <AVFoundation/AVFoundation.h>

@interface ReaderController()

@property (nonatomic) BOOL resultReady;
@property (nonatomic, strong) ACRResult *result;

@property (nonatomic) BOOL customIDReady;
@property (nonatomic) BOOL deviceIDReady;

@property (nonatomic) BOOL plugged;
@property (nonatomic, strong) CardReader *cardReader;
@property (nonatomic, strong) ACRAudioJackReader *reader;
@property (nonatomic, strong) NSCondition *responseCondition;

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
        
        self.resultReady = NO;
        self.customIDReady = NO;
        self.deviceIDReady = NO;

        self.plugged = NO;
        
        self.cardReader = [CardReader sharedInstance];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

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
    // Listen the audio route change.
    /* Legacy
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                    AJDAudioRouteChangeListener,
                                    (__bridge void *) self);
    */
}

- (void)resetReaderController
{
    // Show the progress.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Resetting the reader..."
                                                   delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    // Reset the reader.
    [self.reader resetWithCompletion:^{
        
        // Hide the progress.
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }];
}

- (void)startDemoMode
{
    [self.cardReader setupDemoReaderIfNeeded];
    
    if (self.pluggedHandler) {
        self.pluggedHandler(self.cardReader);
    }
    
    [self didUpdateReader];
}

#pragma mark - Accessors

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
    [self onInfo: CURRENT_METHOD];
    
    [self.reader setMute: !plugged];
    
    [self.cardReader setPlugged: plugged];
    
    [self tryRequestPrimaryDataIdNeeded: YES];
    
    if (self.pluggedHandler) {
        self.pluggedHandler(self.cardReader);
    }
}

#pragma mark - Working methods

- (void)didUpdateReader
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate readerController: self didUpdateWithReader: self.cardReader];
    });
}

- (void)tryRequestPrimaryDataIdNeeded:(BOOL)shouldReset
{
    [self onInfo: CURRENT_METHOD];
    
    if ([self.cardReader isReady]) {
        [self didUpdateReader];
    }
    else if (self.cardReader.isPlugged) {
        if (shouldReset) {
            [self.reader resetWithCompletion:^{
                [self requestPrimaryData];
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
    NSLog(@"Processing the track data...");
}

- (void)reader:(ACRAudioJackReader *)reader didSendTrackData:(ACRTrackData *)trackData
{
    NSLog(@"didSendTrackData...");
    
    NSString *errorString = nil;
    
    if ((trackData.track1ErrorCode == ACRTrackErrorSuccess) &&
        (trackData.track2ErrorCode == ACRTrackErrorSuccess))
    {
        if ([trackData isKindOfClass:[ACRAesTrackData class]])
        {
            ACRAesTrackData *aesTrackData = (ACRAesTrackData *) trackData;
            
            AesTrackData *trackData = [AesTrackData emptyTrack];
            [trackData setTr1Code: 0];
            [trackData setTr2Code: 0];
            [trackData setTr1Length: (int)(aesTrackData.track1Length)];
            [trackData setTr2Length: (int)(aesTrackData.track2Length)];
            [trackData setPlainHexData: [HexCvtr hexFromData: aesTrackData.trackData]];
            
            NSLog(@"Generate trackData with Success: %@", [trackData debugDescription]);
            [self.cardReader setTrackData: trackData];
            
            //
            [self didUpdateReader];
        }
        else {
            XT_MAKE_EXEPTION;
        }

    }
    else if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) &&
             (trackData.track2ErrorCode != ACRTrackErrorSuccess))
    {
        errorString = @"The track 1 and track 2 data";
    }
    else
    {
        if (trackData.track1ErrorCode != ACRTrackErrorSuccess) {
            errorString = @"The track 1 data";
        }
        
        if (trackData.track2ErrorCode != ACRTrackErrorSuccess) {
            errorString = @"The track 2 data";
        }
    }
    
    if (errorString) {
        errorString = [errorString stringByAppendingString:@" may be corrupted. Please swipe the card again!"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: errorString
                                                            message: nil
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK" otherButtonTitles: nil];
            [alert show];
        });
    }
}

- (void)reader:(ACRAudioJackReader *)reader didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length
{
    NSLog(@"");
}

- (void)reader:(ACRAudioJackReader *)reader didSendCustomId:(const uint8_t *)customId length:(NSUInteger)length
{
    [self.responseCondition lock];
    
    self.customIDReady = YES;
    NSData *data = [NSData dataWithBytes: customId length: length];
    [self.cardReader setupWithCustomID: [HexCvtr hexFromData: data]];
    
    [self.responseCondition signal];
    [self.responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length
{
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

/**
 * Returns <code>YES</code> if the reader is plugged, otherwise <code>NO</code>.
 */
//static BOOL AJDIsReaderPlugged() {
//
//    BOOL plugged = NO;
//    CFStringRef route = NULL;
//    UInt32 routeSize = sizeof(route);
//
//    if (AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route) == kAudioSessionNoError) {
//        if (CFStringCompare(route, CFSTR("HeadsetInOut"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
//            plugged = YES;
//        }
//    }
//
//    return plugged;
//}

/**
 * Listens the audio route change.
 * @param inClientData the <code>AJDMasterViewController</code> object.
 * @param inID         the <code>kAudioSessionProperty_AudioRoute</code>
 *                     constant.
 * @param inDataSize   the property size.
 * @param inData       the property.
 */
//static void AJDAudioRouteChangeListener(void *inClientData,
//                                        AudioSessionPropertyID inID,
//                                        UInt32 inDataSize,
//                                        const void *inData) {
//
//    ReaderController *ctr = (__bridge ReaderController *) inClientData;
//
//    // Set mute to YES if the reader is unplugged, otherwise NO.
//    [ctr setPlugged: AJDIsReaderPlugged()];
//}

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
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPlugged: AJDIsReaderPlugged()];
            });
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPlugged: AJDIsReaderPlugged()];
            });
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            // called at start - also when other audio wants to play
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPlugged: AJDIsReaderPlugged()];
            });
        }
            break;
            
        default:
            break;
    }
}

@end
