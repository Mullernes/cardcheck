//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CFinishCheckResponseModel : APIBaseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data;

@end



