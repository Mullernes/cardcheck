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

- (NSString *)calcOtp:(long long)plain
{
    NSNumber *otp = [self hotpWithValue: plain
                                andHexKey: [[KeyChainData sharedInstance] customId]];
    
    return [self semanticOtp: [otp stringValue]];
}

- (NSString *)calcSignature1:(NSData *)plain
{
    NSString *key = [[KeyChainData sharedInstance] commKey];
    NSNumber *otp = [self hotpWithData: plain andHexKey: key];
    
    return [self semanticOtp: [otp stringValue]];
}

- (NSString *)calcSignature2:(NSData *)plain
{
    NSString *key = [[KeyChainData sharedInstance] customId];
    NSNumber *otp = [self hotpWithData: plain andHexKey: key];
    
    return [self semanticOtp: [otp stringValue]];
}

- (NSString *)semanticOtp:(NSString *)value
{
    if ([value length] == 6) {
        return value;
    }
    else if ([value length] == 5) {
        return [NSString stringWithFormat:@"0%@",value];
    }
    else {
        XT_MAKE_EXEPTION;
    }
}

- (NSData *)swapInt32HostToBig:(int)value
{
    uint32_t tValue = value;
    uint32_t tBytes = CFSwapInt32HostToBig(tValue);
    NSData *tData = [NSData dataWithBytes: &tBytes length: sizeof(tBytes)];
    
    return tData.copy;
}

- (NSData *)swapInt64HostToBig:(long long)value
{
    uint64_t tValue = value;
    uint64_t tBytes = CFSwapInt64HostToBig(tValue);
    NSData *tData = [NSData dataWithBytes: &tBytes length: sizeof(tBytes)];
    
    return tData.copy;
}

- (NSString *)calcTransportKey:(InitializationData *)data
{
    //Gen key - 14 bytes
    NSMutableData *keyBuffer = [NSMutableData dataWithCapacity: 14];
    [keyBuffer appendData: [HexCvtr dataFromHex: data.customID]];
    [keyBuffer appendData: [self swapInt32HostToBig: data.otp]];
    
    //Gen data - 32 bytes
    NSMutableData *dataBuffer = [NSMutableData dataWithCapacity: 32];

    [dataBuffer appendData: [self swapInt64HostToBig: data.authRequestTime]];
    [dataBuffer appendData: [self swapInt64HostToBig: data.authResponseTime]];
    [dataBuffer appendData: [self swapInt64HostToBig: data.devInitRequestTime]];
    [dataBuffer appendData: [self swapInt64HostToBig: data.devInitResponseTime]];
    
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
    /* for debug
    NSLog(@"==== hotp =====");
    NSLog(@"data = %@, length = %li", [HexCvtr hexFromData: plain], [plain length]);
    NSLog(@"key = %@, length = %li", key, [[HexCvtr dataFromHex: key] length]);
     */
    
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
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [key bytes], [key length], [plain bytes], [plain length], cHMAC);
    
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

