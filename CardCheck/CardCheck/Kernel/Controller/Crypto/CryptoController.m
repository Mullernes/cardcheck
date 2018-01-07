//
//  CryptoController.m
//  CardCheck
//
//  Created by itnesPro on 12/24/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CryptoController.h"
#import "AJDHex.h"

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

- (NSData *)hmac1WithPlainText:(NSString *)plain andHexKey:(NSString *)key
{
    const char *cText = [plain cStringUsingEncoding: NSUTF8StringEncoding];
    return [self hmac1WithPlainData: [plain dataUsingEncoding: NSUTF8StringEncoding]
                         andKeyData: [[key hexToData] copy]];
}

- (NSData *)hmac1WithPlainData:(NSData *)plain andHexKey:(NSString *)key
{
    return [self hmac1WithPlainData: plain.copy andKeyData: [[key hexToData] copy]];
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

- (NSNumber *)hotpWithPlainData:(NSData *)plain andHexKey:(NSString *)key
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

- (NSNumber *)hotpWithPlainText:(NSString *)plain andHexKey:(NSString *)key
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

- (NSNumber *)hotpWithPlainValue:(long long)plain andHexKey:(NSString *)key
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

- (NSString *)calcTransportKey:(DevInitData *)data
{
    //Gen key - 14 bytes
    NSMutableData *keyBuffer = [NSMutableData dataWithCapacity: 14];
    [keyBuffer appendData: [data.customID hexToData]];
    
    NSUInteger otp = data.otp;
    NSData *otpData = [NSData dataWithBytes: &otp length: sizeof(otp)];
    [keyBuffer appendBytes: [otpData bytes] length: 4];
    
    //Gen data - 32 bytes
    NSData *timeD = nil;
    long long timeT = 0;
    NSMutableData *dataBuffer = [NSMutableData dataWithCapacity: 32];

    /*
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
    */
    
    timeT = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    timeD = [NSData dataWithBytes: &timeT length: sizeof(timeT)];
    [dataBuffer appendData: timeD];
    [dataBuffer appendData: timeD];
    [dataBuffer appendData: timeD];
    [dataBuffer appendData: timeD];
    
    //hmac1
    NSData *hmac1Data = [self hmac1WithPlainData: dataBuffer.copy
                                     andKeyData: keyBuffer.copy];
    
    //transport key
    NSData *transportKey = [hmac1Data subdataWithRange: NSMakeRange(0, 16)];
    
    return [[AJDHex hexStringFromByteArray: transportKey] copy];
}



@end
