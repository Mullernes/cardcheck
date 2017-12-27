//
//  CryptoController.m
//  CardCheck
//
//  Created by itnesPro on 12/24/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CryptoController.h"

#include <CommonCrypto/CommonHMAC.h>

@implementation CryptoController

#pragma mark - Init

+ (instancetype)sharedInstance
{
    static CryptoController *CRPController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CRPController = [[self alloc] init];
    });
    return CRPController;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

- (NSData *)hmac1WithText:(NSString *)plain andSecret:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding: NSUTF8StringEncoding];
    const char *cText = [plain cStringUsingEncoding: NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cText, strlen(cText), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes: cHMAC
                                          length: sizeof(cHMAC)];
                    
    return HMAC.copy;
}

- (int)hotpWithText:(NSString *)plainText andSecret:(NSString *)secretKey
{
    NSData *data = [self hmac1WithText: plainText andSecret: secretKey];
    const char *cHMAC = [data bytes];
    
    int value = 0;
    int offset = 0;
    offset = cHMAC[CC_SHA1_DIGEST_LENGTH - 1] & 0x0f;
    
    value = ((cHMAC[offset] & 0x7f) << 24)     |
            ((cHMAC[offset + 1] & 0xff) << 16) |
            ((cHMAC[offset + 2] & 0xff) << 8)  |
            (cHMAC[offset + 3] & 0xff);
    value = value % 1000000;
    
    return value;
}


@end
