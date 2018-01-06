//
//  ReaderController.h
//  CardCheck
//
//  Created by itnesPro on 1/5/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

@interface ReaderController : KLBaseController

#pragma mark - Init
+ (instancetype)sharedInstance;

- (void)initReader;
- (void)getDeviceID;

@end
