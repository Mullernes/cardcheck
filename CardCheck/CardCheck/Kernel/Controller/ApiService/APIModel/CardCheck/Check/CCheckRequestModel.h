//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CCheckRequestModel : APIBaseModel

@property (nonatomic, readonly) long appId;
@property (nonatomic, strong, readonly) NSString *appVersion;
@property (nonatomic, strong, readonly) CardReaderData *reader;

+ (instancetype)requestWithReader:(CardReaderData *)reader;

@end



