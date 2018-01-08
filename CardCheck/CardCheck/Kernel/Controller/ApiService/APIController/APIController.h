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

typedef void(^AuthResponseHandler)(AuthResponseModel *model, NSError *error);
typedef void(^DevInitResponseHandler)(InitResponseModel *model, NSError *error);

@interface APIController : KLBaseController

#pragma mark - Init
+ (instancetype)sharedInstance;

- (void)sendAuthRequest:(AuthRequestModel *)request
         withCompletion:(AuthResponseHandler)handler;


- (void)sendDevInitRequest:(InitRequestModel *)request
            withCompletion:(DevInitResponseHandler)handler;

@end
