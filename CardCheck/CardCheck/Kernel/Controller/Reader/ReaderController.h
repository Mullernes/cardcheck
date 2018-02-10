//
//  ReaderController.h
//  CardCheck
//
//  Created by itnesPro on 1/5/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

@protocol ReaderControllerDelegate;
typedef void(^ReaderPluggedHandler)(CardReader *reader);

@interface ReaderController : KLBaseController

@property (nonatomic) ReaderPluggedHandler pluggedHandler;
@property (nonatomic, weak) id<ReaderControllerDelegate>delegate;

#pragma mark - Init
+ (instancetype)sharedInstance;
- (void)resetReaderController;

- (void)startDemoMode;

@end

@protocol ReaderControllerDelegate <NSObject>
- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader;
@end
