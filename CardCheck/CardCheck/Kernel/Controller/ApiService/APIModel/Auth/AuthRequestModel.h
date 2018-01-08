//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface AuthRequestModel : APIBaseModel

@property (nonatomic, strong, readonly) NSString *login;
@property (nonatomic, strong, readonly) CardReaderData *reader;

+ (instancetype)requestWithLogin:(NSString *)login
                       andReader:(CardReaderData *)reader;

@end



