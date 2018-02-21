//
//  HexCvtr.h
//  CardCheck
//
//  Created by itnesPro on 1/7/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HexCvtr : NSObject

+ (NSData *)dataFromHex:(NSString *)hex;
+ (NSString *)hexFromData:(NSData *)data;
+ (NSString *)hexFromString:(NSString *)string;

@end
