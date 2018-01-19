//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CCheckRequestModel : APIBaseModel

+ (instancetype)requestWithReader:(CardReaderData *)reader;

@end



