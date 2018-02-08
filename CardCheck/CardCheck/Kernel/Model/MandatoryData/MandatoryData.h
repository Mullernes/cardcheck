//
//  MandatoryData.h
//  CardCheck
//
//  Created by itnesPro on 1/8/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface MandatoryData : KLBaseModel

@property (nonatomic, readonly, getter=isExist) BOOL exist;

@property (nonatomic) long appID;
@property (nonatomic, strong) NSString *deviceID;       //8 bytes MCU
@property (nonatomic, strong) NSString *appDataKey;     //32 bytes for AES256
@property (nonatomic, strong) NSString *appCommKey;     //42 bytes

#pragma mark - Init
+ (instancetype)sharedInstance;

- (void)save;
- (void)clean;


@end
