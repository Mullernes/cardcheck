//
//  DevInitRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 1/2/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface DevInitRequestModel : APIBaseModel

@property (nonatomic, strong, readonly) DevInitData *data;
@property (nonatomic, strong, readonly) CardReaderData *reader;

+ (instancetype)requestWithData:(DevInitData *)data
                      andReader:(CardReaderData *)reader;

@end
