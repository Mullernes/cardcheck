//
//  APIController.h
//  CardCheck
//
//  Created by itnesPro on 12/27/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

typedef void(^AuthResponseHandler)(AuthResponseModel *model, NSError *error);

@interface APIController : KLBaseController

#pragma mark - Init
+ (instancetype)sharedInstance;

- (void)sendAuthRequest:(AuthRequestModel *)model withCompletion:(AuthResponseHandler)handler;

@end
