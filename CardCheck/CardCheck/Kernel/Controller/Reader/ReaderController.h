//
//  ReaderController.h
//  CardCheck
//
//  Created by itnesPro on 1/5/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

typedef NS_ENUM(NSInteger, ReaderState) {
    
    ReaderStatePreparing,
    ReaderStateReady,
    ReaderStateGettingData
};

@protocol ReaderControllerDelegate;
typedef void(^ReaderPluggedHandler)(CardReader *reader);


@interface ReaderController : KLBaseController


@property (nonatomic, getter=isStaging) BOOL stage;
@property (nonatomic) ReaderPluggedHandler pluggedHandler;
@property (nonatomic, weak) id<ReaderControllerDelegate>delegate;

#pragma mark - Init
+ (instancetype)sharedInstance;
- (void)resetReaderController;

- (void)startDemoMode;

@end


@protocol ReaderControllerDelegate <NSObject>
@optional

- (void)readerController:(ReaderController *)controller didUpdateWithState:(ReaderState)state;
- (void)readerController:(ReaderController *)controller didUpdateWithCounter:(NSUInteger)counter;

- (void)readerController:(ReaderController *)controller didReceiveTrackData:(TrackData *)data;
- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader;

@end
