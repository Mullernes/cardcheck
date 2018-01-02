//
//  CryptoController.m
//  CardCheck
//
//  Created by itnesPro on 12/24/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CryptoController.h"

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

#pragma mark - hmac1

- (NSData *)hmac1WithText:(NSString *)plain andSecret:(NSString *)key
{
    const char *cKey  = [[key hexToBytes] bytes];
    const char *cText = [plain cStringUsingEncoding: NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cText, strlen(cText), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes: cHMAC
                                          length: sizeof(cHMAC)];
                    
    return HMAC.copy;
}

- (NSData *)hmac1WithData:(NSData *)plain andSecret:(NSString *)key
{
    const char *cKey  = [[key hexToBytes] bytes];
    const char *cText = [plain bytes];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cText, [plain length], cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes: cHMAC
                                          length: sizeof(cHMAC)];
    
    return HMAC.copy;
}

- (NSNumber *)hotpWithData:(NSData *)plainData andSecret:(NSString *)secretKey
{
    NSData *data = [self hmac1WithData: plainData andSecret: secretKey];
    const char *cHMAC = [data bytes];
    
    int otp = 0;
    int offset = 0;
    offset = cHMAC[CC_SHA1_DIGEST_LENGTH - 1] & 0x0f;
    
    otp =   ((cHMAC[offset] & 0x7f) << 24)     |
            ((cHMAC[offset + 1] & 0xff) << 16) |
            ((cHMAC[offset + 2] & 0xff) << 8)  |
            (cHMAC[offset + 3] & 0xff);
    otp = otp % 1000000;
    
    return [NSNumber numberWithInt: otp];
}

- (NSNumber *)hotpWithText:(NSString *)plainText andSecret:(NSString *)secretKey
{
    NSData *data = [self hmac1WithText: plainText andSecret: secretKey];
    const char *cHMAC = [data bytes];
    
    int otp = 0;
    int offset = 0;
    offset = cHMAC[CC_SHA1_DIGEST_LENGTH - 1] & 0x0f;
    
    otp =   ((cHMAC[offset] & 0x7f) << 24)     |
            ((cHMAC[offset + 1] & 0xff) << 16) |
            ((cHMAC[offset + 2] & 0xff) << 8)  |
            (cHMAC[offset + 3] & 0xff);
    otp = otp % 1000000;
    
    return [NSNumber numberWithInt: otp];
}

- (NSNumber *)hotpWithValue:(long long)plainValue andSecret:(NSString *)secretKey
{
    uint64_t tValue = plainValue;
    uint64_t tBytes = CFSwapInt64HostToBig(tValue);
    NSData *tPlainData = [NSData dataWithBytes: &tBytes length: sizeof(tBytes)];

    NSData *hmacData = [self hmac1WithData: tPlainData andSecret: secretKey];
    const char *cHMAC = [hmacData bytes];

    int otp = 0;
    int offset = 0;
    offset = cHMAC[CC_SHA1_DIGEST_LENGTH - 1] & 0x0f;

    otp =   ((cHMAC[offset] & 0x7f) << 24)     |
            ((cHMAC[offset + 1] & 0xff) << 16) |
            ((cHMAC[offset + 2] & 0xff) << 8)  |
            (cHMAC[offset + 3] & 0xff);
    otp = otp % 1000000;

    return [NSNumber numberWithInt: otp];
}


@end
