//
//  APIController.h
//  CardCheck
//
//  Created by itnesPro on 12/27/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

#import "AuthRequestModel.h"
#import "AuthResponseModel.h"

#import "InitRequestModel.h"
#import "InitResponseModel.h"

#import "CCheckRequestModel.h"
#import "CCheckResponseModel.h"

#import "CFinishCheckRequestModel.h"
#import "CFinishCheckResponseModel.h"

typedef void(^AuthResponseHandler)(AuthResponseModel *model, NSError *error);
typedef void(^DevInitResponseHandler)(InitResponseModel *model, NSError *error);
typedef void(^CCheckResponseHandler)(CCheckResponseModel *model, NSError *error);
typedef void(^CFinishCheckResponseHandler)(CFinishCheckResponseModel *model, NSError *error);

@interface APIController : KLBaseController

#pragma mark - Init
+ (instancetype)sharedInstance;

- (void)sendAuthRequest:(AuthRequestModel *)request
         withCompletion:(AuthResponseHandler)handler;

- (void)sendDevInitRequest:(InitRequestModel *)request
            withCompletion:(DevInitResponseHandler)handler;

- (void)sendCCheckRequest:(CCheckRequestModel *)request
           withCompletion:(CCheckResponseHandler)handler;

- (void)sendCFinishCheckRequest:(CFinishCheckRequestModel *)request
                 withCompletion:(CFinishCheckResponseHandler)handler;

- (void)uploadImageRequest:(CCheckResponseModel *)model;

@end
