//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CUploadResponseModel : APIBaseModel

@property (nonatomic, readonly) long imgID;
@property (nonatomic, readonly) long imgSize;
@property (nonatomic, readonly) long imgCRC32;

+ (instancetype)responseWithRawData:(NSDictionary *)data;

@end



