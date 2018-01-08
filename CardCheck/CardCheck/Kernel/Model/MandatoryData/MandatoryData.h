//
//  MandatoryData.h
//  CardCheck
//
//  Created by itnesPro on 1/8/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface MandatoryData : KLBaseModel

@property (nonatomic, readonly) long appID;
@property (nonatomic, strong, readonly) NSString *deviceID;     //MCU
@property (nonatomic, strong, readonly) NSString *appDataKey;
@property (nonatomic, strong, readonly) NSString *appCommKey;

@end
