//
//  CryptoController.m
//  CardCheck
//
//  Created by itnesPro on 12/24/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CryptoController.h"
#import "NSData+AES.h"

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

#pragma mark - Working methods

- (NSUInteger)calcOtp:(long long)plain
{
    NSNumber *value = [self hotpWithValue: plain
                                andHexKey: [[KeyChainData sharedInstance] customId]];
    
    return [value unsignedIntegerValue];
}

- (NSString *)calcSignature1:(NSData *)plain
{
    NSString *key = [[KeyChainData sharedInstance] commKey];
    NSNumber *otp = [self hotpWithData: plain andHexKey: key];
    
    return [otp stringValue];
}

- (NSString *)calcSignature2:(NSData *)plain
{
    NSString *key = [[KeyChainData sharedInstance] customId];
    NSNumber *otp = [self hotpWithData: plain andHexKey: key];
    
    return [otp stringValue];
}

- (NSString *)calcTransportKey:(InitializationData *)data
{
    //Gen key - 14 bytes
    NSMutableData *keyBuffer = [NSMutableData dataWithCapacity: 14];
    [keyBuffer appendData: [HexCvtr dataFromHex: data.customID]];
    
    NSUInteger otp = data.otp;
    NSData *otpData = [NSData dataWithBytes: &otp length: sizeof(otp)];
    [keyBuffer appendBytes: [otpData bytes] length: 4];
    
    //Gen data - 32 bytes
    NSData *timeD = nil;
    long long timeT = 0;
    NSMutableData *dataBuffer = [NSMutableData dataWithCapacity: 32];
    
    if (DEMO_MODE) {
        timeT = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        timeD = [NSData dataWithBytes: &timeT length: sizeof(timeT)];
        [dataBuffer appendData: timeD];
        [dataBuffer appendData: timeD];
        [dataBuffer appendData: timeD];
        [dataBuffer appendData: timeD];
    }
    else {
        timeT = data.authRequestTime;
        timeD = [NSData dataWithBytes: &timeT length: sizeof(timeT)];
        [dataBuffer appendData: timeD];
        
        timeT = data.authResponseTime;
        timeD = [NSData dataWithBytes: &timeT length: sizeof(timeT)];
        [dataBuffer appendData: timeD];
        
        timeT = data.devInitRequestTime;
        timeD = [NSData dataWithBytes: &timeT length: sizeof(timeT)];
        [dataBuffer appendData: timeD];
        
        timeT = data.devInitResponseTime;
        timeD = [NSData dataWithBytes: &timeT length: sizeof(timeT)];
        [dataBuffer appendData: timeD];
    }
    
    //hmac1
    NSData *hmac1Data = [self hmac1WithPlainData: dataBuffer.copy
                                      andKeyData: keyBuffer.copy];
    
    //transport key
    NSData *transportKey = [hmac1Data subdataWithRange: NSMakeRange(0, 16)];
    
    return [HexCvtr hexFromData: transportKey];
}

#pragma mark - Hotp

- (NSNumber *)hotpWithText:(NSString *)plain andHexKey:(NSString *)key
{
    NSData *data = [self hmac1WithPlainText: plain andHexKey: key];
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

- (NSNumber *)hotpWithData:(NSData *)plain andHexKey:(NSString *)key
{
    NSData *data = [self hmac1WithPlainData: plain andHexKey: key];
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

- (NSNumber *)hotpWithValue:(long long)plain andHexKey:(NSString *)key
{
    uint64_t tValue = plain;
    uint64_t tBytes = CFSwapInt64HostToBig(tValue);
    NSData *tPlainData = [NSData dataWithBytes: &tBytes length: sizeof(tBytes)];
    
    NSData *hmacData = [self hmac1WithPlainData: tPlainData andHexKey: key];
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

#pragma mark - hmac1

- (NSData *)hmac1WithPlainText:(NSString *)plain andHexKey:(NSString *)key
{
    return [self hmac1WithPlainData: [plain dataUsingEncoding: NSUTF8StringEncoding]
                         andKeyData: [HexCvtr dataFromHex: key]];
}

- (NSData *)hmac1WithPlainData:(NSData *)plain andHexKey:(NSString *)key
{
    return [self hmac1WithPlainData: plain.copy
                         andKeyData: [HexCvtr dataFromHex: key]];
}

- (NSData *)hmac1WithPlainData:(NSData *)plain andKeyData:(NSData *)key
{
    const char *cKey  = [key bytes];
    const char *cText = [plain bytes];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cText, [plain length], cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes: cHMAC
                                          length: sizeof(cHMAC)];
    
    return HMAC.copy;
}

#pragma mark - AES

- (NSData *)aes128EncryptHexData:(NSString *)data withHexKey:(NSString *)key
{
    NSData *inputData = [HexCvtr dataFromHex: data];
    return [inputData AES128EncryptedDataWithKey: key];
}

- (NSData *)aes128DecryptHexData:(NSString *)data withHexKey:(NSString *)key
{
    NSData *inputData = [HexCvtr dataFromHex: data];
    return [inputData AES128DecryptedDataWithKey: key];
}

- (NSData *)aes256EncryptHexData:(NSString *)data withHexKey:(NSString *)key
{
    NSData *inputData = [HexCvtr dataFromHex: data];
    return [inputData AES256EncryptedDataWithKey: key];
}

- (NSData *)aes256DecryptHexData:(NSString *)data withHexKey:(NSString *)key
{
    NSData *inputData = [HexCvtr dataFromHex: data];
    return [inputData AES256DecryptedDataWithKey: key];
}


@end

