//
//  HexCvtr.h
//  CardCheck
//
//  Created by itnesPro on 1/7/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HexCvtr : NSObject

+ (NSString *)hexFromData:(NSData *)data;
+ (NSData *)dataFromHex:(NSString *)hex;

@end
