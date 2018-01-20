//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CUploadRequestModel : APIBaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) CardImage *cardImg;

+ (instancetype)requestWithReportID:(long)rID
                         reportTime:(long long)time
                          cardImage:(CardImage *)image;

@end



