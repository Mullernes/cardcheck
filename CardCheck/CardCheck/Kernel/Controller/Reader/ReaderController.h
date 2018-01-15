//
//  ReaderController.h
//  CardCheck
//
//  Created by itnesPro on 1/5/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

@protocol ReaderControllerDelegate;

@interface ReaderController : KLBaseController

@property (nonatomic, weak) id<ReaderControllerDelegate>delegate;

#pragma mark - Init
+ (instancetype)sharedInstance;
- (void)start;
- (void)reset;

@end

@protocol ReaderControllerDelegate <NSObject>
- (void)readerController:(ReaderController *)controller didReceiveData:(CardReaderData *)data;
@end
