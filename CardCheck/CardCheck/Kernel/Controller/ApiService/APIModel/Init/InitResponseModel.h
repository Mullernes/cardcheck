//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface InitResponseModel : APIBaseModel

@property (nonatomic, readonly) int code;
@property (nonatomic, readonly) long appID;
@property (nonatomic, readonly) NSString *appKeys;

+ (instancetype)responseWithRawData:(NSDictionary *)data;

@end



