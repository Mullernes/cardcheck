#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES)

#pragma mark - AES128

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key
{
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key
{
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    memcpy(keyPtr, [[HexCvtr dataFromHex: key] bytes], kCCKeySizeAES128);

    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        memcpy(ivPtr, [[HexCvtr dataFromHex: iv] bytes], kCCBlockSizeAES128);
    }

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          0,
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *cipherData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return cipherData;
    }
    free(buffer);
    return nil;
}

#pragma mark - AES256

- (NSData *)AES256EncryptedDataWithKey:(NSString *)key
{
    return [self AES256EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES256DecryptedDataWithKey:(NSString *)key
{
    return [self AES256DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES256EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES256Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES256DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES256Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)AES256Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    memcpy(keyPtr, [[HexCvtr dataFromHex: key] bytes], kCCKeySizeAES256);
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        memcpy(ivPtr, [[HexCvtr dataFromHex: iv] bytes], kCCBlockSizeAES128);
    }
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          0,
                                          keyPtr,
                                          kCCKeySizeAES256,
                                          0,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *cipherData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return cipherData;
    }
    free(buffer);
    return nil;
}

- (NSUInteger)crc32
{
    uint32_t *table = malloc(sizeof(uint32_t) * 256);
    uint32_t crc = 0xffffffff;
    uint8_t *bytes = (uint8_t *)[self bytes];
    
    for (uint32_t i=0; i<256; i++) {
        table[i] = i;
        for (int j=0; j<8; j++) {
            if (table[i] & 1) {
                table[i] = (table[i] >>= 1) ^ 0xedb88320;
            } else {
                table[i] >>= 1;
            }
        }
    }
    
    for (int i=0; i<self.length; i++) {
        crc = (crc >> 8) ^ table[(crc & 0xff) ^ bytes[i]];
    }
    crc ^= 0xffffffff;
    
    free(table);
    return crc;
}



@end
