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

- (NSNumber *)hotpWithData:(NSData *)plain andHexKey:(NSString *)key;
- (NSNumber *)hotpWithText:(NSString *)plain andHexKey:(NSString *)key;
- (NSNumber *)hotpWithValue:(long long)plain andHexKey:(NSString *)key;
- (NSString *)calcTransportKey:(DevInitData *)data;

- (NSData *)aes128EncryptHexData:(NSString *)data withHexKey:(NSString *)key;
- (NSData *)aes128DecryptHexData:(NSString *)data withHexKey:(NSString *)key;

@end
