//
//  HexCvtr.m
//  CardCheck
//
//  Created by itnesPro on 1/7/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "HexCvtr.h"

@implementation HexCvtr

+ (NSString *)hexFromString:(NSString *)string
{
    return [HexCvtr hexFromData: [string dataUsingEncoding: NSUTF8StringEncoding]];
}

+ (NSString *)hexFromData:(NSData *)data
{
    unsigned char *dataBuffer = (unsigned char *)[[data copy] bytes];
    if (!dataBuffer) {
        return @"";
    }
    else {
        NSUInteger dataLength = [data length];
        NSMutableString *hexString = [NSMutableString stringWithCapacity: dataLength*2];
        for (int i = 0; i < dataLength; ++i) {
            //[hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
            [hexString appendString:[NSString stringWithFormat:@"%.2X", dataBuffer[i]]];
        }
        return [[NSString stringWithString: hexString] copy];
    }
}

+ (NSData *)dataFromHex:(NSString *)hex
{
    if (hex.length) {
        NSMutableData *data = [NSMutableData data];
        
        int idx;
        for (idx = 0; idx+2 <= hex.length; idx+=2)
        {
            NSRange range = NSMakeRange(idx, 2);
            NSString *hexStr = [hex substringWithRange: range];
            NSScanner *scanner = [NSScanner scannerWithString: hexStr];
            
            unsigned int intValue;
            [scanner scanHexInt: &intValue];
            [data appendBytes: &intValue length: 1];
        }
        return [data copy];
    }
    else {
        return [NSData data];
    }
}

@end
