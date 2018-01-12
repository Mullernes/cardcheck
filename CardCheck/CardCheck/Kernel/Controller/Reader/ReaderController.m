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

@interface ReaderController()

@property (nonatomic) BOOL resultReady;
@property (nonatomic, strong) ACRResult *result;

@property (nonatomic) BOOL customIDReady;
@property (nonatomic) BOOL deviceIDReady;

@property (nonatomic) BOOL plugged;
@property (nonatomic, strong)CardReaderData *readerData;
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
        
        self.readerData = [CardReaderData emptyData];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

- (void)start
{
    [self onInfo: CURRENT_METHOD];
    
    self.responseCondition = [[NSCondition alloc] init];
    
    self.reader = [[ACRAudioJackReader alloc] initWithMute: YES];
    [self.reader setDelegate: self];
    
    // Set mute to YES if the reader is unplugged, otherwise NO.
    self.reader.mute = !AJDIsReaderPlugged();
    
    // Listen the audio route change.
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                    AJDAudioRouteChangeListener,
                                    (__bridge void *) self);
}


#pragma mark - Accessors

- (void)setPlugged:(BOOL)plugged
{
    [self onInfo: CURRENT_METHOD];
    
    [self.reader setMute: !plugged];
    [self.readerData setPlugged: plugged];
    
    [self.delegate readerController: self didReceiveData: self.readerData];
    
    if (self.readerData.isPlugged) {
        [self requestDeviceIDIfNeeded];
        [self requestCustomIDIfNeeded];
    }
}

- (void)requestCustomIDIfNeeded
{
    [self onInfo: CURRENT_METHOD];
    
    if (self.readerData.customID == nil)
    {
        // Reset the reader.
        [self.reader resetWithCompletion:^{
            
            self.resultReady = NO;
            self.customIDReady = NO;
            
            if (NO == [self.reader getCustomId]) {
                NSLog(@"The request cannot be queued");
            } else {
                [self requestCustomID];
            }
        }];
    }
}

- (void)requestCustomID
{
    [self onInfo: CURRENT_METHOD];
    
    [self.responseCondition lock];
    
    // Wait for the custom ID.
    while ( (NO == self.customIDReady)  && (NO == self.resultReady) ) {
        if (NO == [self.responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }
    
    if (self.customIDReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate readerController: self didReceiveData: self.readerData];
        });
        
    } else if (self.resultReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [self completionError: [self currentClass]
                                         andReason: @"%@ resultCode = %ui", CURRENT_METHOD, self.result.errorCode];
            [self onFailure: error];
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [self completionError: [self currentClass]
                                         andReason: @"%@ Timeout", CURRENT_METHOD];
            [self onFailure: error];
        });
    }
    
    self.customIDReady = NO;
    self.resultReady = NO;
    
    [self.responseCondition unlock];
}

- (void)requestDeviceIDIfNeeded
{
    [self onInfo: CURRENT_METHOD];
    
    if (self.readerData.deviceID == nil)
    {
        // Reset the reader.
        [self.reader resetWithCompletion:^{
            
            self.resultReady = NO;
            self.deviceIDReady = NO;
            
            if (NO == [self.reader getDeviceId]) {
                NSLog(@"The request cannot be queued");
            } else {
                [self requestDeviceID];
            }
        }];
    }
}

- (void)requestDeviceID
{
    [self onInfo: CURRENT_METHOD];
    
    [self.responseCondition lock];
    
    // Wait for the custom ID.
    while ( (NO == self.deviceIDReady)  && (NO == self.resultReady) ) {
        if (NO == [self.responseCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            break;
        }
    }
    
    if (self.deviceIDReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate readerController: self didReceiveData: self.readerData];
        });
        
    } else if (self.resultReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [self completionError: [self currentClass]
                                         andReason: @"%@ resultCode = %ui", CURRENT_METHOD, self.result.errorCode];
            [self onFailure: error];
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [self completionError: [self currentClass]
                                         andReason: @"%@ Timeout", CURRENT_METHOD];
            [self onFailure: error];
        });
    }
    
    self.deviceIDReady = NO;
    self.resultReady = NO;
    
    [self.responseCondition unlock];
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

- (void)reader:(ACRAudioJackReader *)reader didSendCustomId:(const uint8_t *)customId length:(NSUInteger)length
{
    [self.responseCondition lock];
    
    self.customIDReady = YES;
    NSData *data = [NSData dataWithBytes: customId length: length];
    [self.readerData setupWithCustomID: [HexCvtr hexFromData: data]];
    
    [self.responseCondition signal];
    [self.responseCondition unlock];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length
{
    [self.responseCondition lock];
    
    self.deviceIDReady = YES;
    NSData *data = [NSData dataWithBytes: deviceId length: length];
    [self.readerData setupWithDeviceID: [HexCvtr hexFromData: data]];
    
    [self.responseCondition signal];
    [self.responseCondition unlock];
}

#pragma mark - Private Functions

/**
 * Returns <code>YES</code> if the reader is plugged, otherwise <code>NO</code>.
 */
static BOOL AJDIsReaderPlugged() {
    
    BOOL plugged = NO;
    CFStringRef route = NULL;
    UInt32 routeSize = sizeof(route);
    
    if (AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route) == kAudioSessionNoError) {
        if (CFStringCompare(route, CFSTR("HeadsetInOut"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            plugged = YES;
        }
    }
    
    return plugged;
}

/**
 * Listens the audio route change.
 * @param inClientData the <code>AJDMasterViewController</code> object.
 * @param inID         the <code>kAudioSessionProperty_AudioRoute</code>
 *                     constant.
 * @param inDataSize   the property size.
 * @param inData       the property.
 */
static void AJDAudioRouteChangeListener(void *inClientData,
                                        AudioSessionPropertyID inID,
                                        UInt32 inDataSize,
                                        const void *inData) {
    
    ReaderController *ctr = (__bridge ReaderController *) inClientData;

    // Set mute to YES if the reader is unplugged, otherwise NO.
    [ctr setPlugged: AJDIsReaderPlugged()];
}

#pragma mark - Debugging

- (NSString *)currentClass {
    return CURRENT_CLASS;
}


@end
