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

- (int)calcOtp:(long long)plain;
- (NSString *)calcSignature1:(NSData *)plain;
- (NSString *)calcSignature2:(NSData *)plain;
- (NSString *)calcTransportKey:(InitializationData *)data;

- (NSData *)aes128EncryptHexData:(NSString *)data withHexKey:(NSString *)key;
- (NSData *)aes128DecryptHexData:(NSString *)data withHexKey:(NSString *)key;

- (NSData *)aes256EncryptHexData:(NSString *)data withHexKey:(NSString *)key;
- (NSData *)aes256DecryptHexData:(NSString *)data withHexKey:(NSString *)key;

@end
