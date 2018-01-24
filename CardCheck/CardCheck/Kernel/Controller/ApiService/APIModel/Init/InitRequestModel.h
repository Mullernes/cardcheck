//
//  DevInitRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 1/2/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface InitRequestModel : APIBaseModel

@property (nonatomic, strong, readonly) InitializationData *data;
@property (nonatomic, strong, readonly) CardReader *reader;

+ (instancetype)requestWithData:(InitializationData *)data
                      andReader:(CardReader *)reader;

@end
