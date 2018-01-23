//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CFinishCheckRequestModel : APIBaseModel

@property (nonatomic, strong) CCheckResponseModel *checkResponse;

+ (instancetype)requestWithReader:(CardReader *)reader;
- (void)setupFakeCardWithImages:(NSArray<CardImage *> *)images;

@end



