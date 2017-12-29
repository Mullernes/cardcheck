//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface AuthRequestModel : APIBaseModel

+ (instancetype)modelWithLogin:(NSString *)login andReader:(CardReader *)reader;

@end



