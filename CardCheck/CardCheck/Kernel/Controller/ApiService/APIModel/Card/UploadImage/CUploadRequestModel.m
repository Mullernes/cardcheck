//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CUploadRequestModel.h"

@interface CUploadRequestModel()

@property (nonatomic) long rId;

@end

@implementation CUploadRequestModel

+ (instancetype)requestWithReportID:(long)rID
                         reportTime:(long long)time
                          cardImage:(CardImage *)image
{
    CUploadRequestModel *model = [CUploadRequestModel new];
    
    [model setRId: rID];
    [model setCardImg: image];
    [model setupWithTime: time];
    
    [model setName: @"image"];
    [model setFileName: @"name"];
    [model setMimeType: @"image/jpeg"];
    
    return model;
}

- (NSDictionary *)parameters
{
    return @{@"report_id"   :   @(self.rId),
             @"report_time" :   @(self.time)};
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
