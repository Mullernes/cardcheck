//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@class CardCheckReport;
@interface CFinishCheckRequestModel : APIBaseModel

+ (instancetype)requestWithReader:(CardReader *)reader;

- (void)setupWithReport:(CardCheckReport *)report;

@end



