//
//  CryptoController.h
//  CardCheck
//
//  Created by itnesPro on 12/24/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

@interface CryptoController : KLBaseController

#pragma mark - Init
+ (instancetype)sharedInstance;
- (int)hotpWithText:(NSString *)plainText andSecret:(NSString *)secretKey;

@end
