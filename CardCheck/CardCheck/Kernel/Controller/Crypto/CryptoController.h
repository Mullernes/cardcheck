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

- (NSNumber *)hotpWithPlainData:(NSData *)plain andHexKey:(NSString *)key;
- (NSNumber *)hotpWithPlainText:(NSString *)plain andHexKey:(NSString *)key;
- (NSNumber *)hotpWithPlainValue:(long long)plain andHexKey:(NSString *)key;
- (NSString *)calcTransportKey:(DevInitData *)data;

@end
