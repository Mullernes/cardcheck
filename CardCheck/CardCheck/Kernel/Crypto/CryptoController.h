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

- (NSNumber *)hotpWithData:(NSData *)plainData andSecret:(NSString *)secretKey;
- (NSNumber *)hotpWithText:(NSString *)plainText andSecret:(NSString *)secretKey;
- (NSNumber *)hotpWithValue:(int)plainValue andSecret:(NSString *)secretKey;

@end
