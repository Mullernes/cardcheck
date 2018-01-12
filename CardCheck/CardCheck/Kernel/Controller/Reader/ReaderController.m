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
        
        self.readerData = [CardReaderData emptyData];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

- (void)start
{
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
    [self.reader setMute: !plugged];
    [self.readerData setPlugged: plugged];
    
    [self.delegate readerController: self didReceiveData: self.readerData];
}

- (void)getDeviceID
{
    // Reset the reader.
    [self.reader resetWithCompletion:^{
        
        // Get the device ID.
        if (![_reader getDeviceId]) {
            // Show the request queue error.
            //[self showRequestQueueError];
            
        } else {
            
            // Show the device ID.
            //[self showDeviceId:idViewController];
        }
        
        // Hide the progress.
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [alert dismissWithClickedButtonIndex:0 animated:YES];
//        });
    }];
}

- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length
{
    [_responseCondition lock];
    NSLog(@"");
    [_responseCondition signal];
    [_responseCondition unlock];
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

@end
