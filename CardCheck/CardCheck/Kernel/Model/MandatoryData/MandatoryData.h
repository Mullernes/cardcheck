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
@property (nonatomic, strong) NSString *deviceID;     //*MCU
@property (nonatomic, strong) NSString *appDataKey;
@property (nonatomic, strong) NSString *appCommKey;

#pragma mark - Init
+ (instancetype)sharedInstance;

- (void)save;

@end
