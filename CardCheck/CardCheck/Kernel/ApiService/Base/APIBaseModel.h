//
//  APIBaseModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface APIBaseModel : KLBaseModel

@property (nonatomic, strong) NSString *signature;

+ (instancetype)responseWithRawData:(NSDictionary *)data;

#pragma mark - Working
- (NSData *)jsonData;
- (NSString *)jsonString;
- (NSDictionary *)parameters;

#pragma mark - Errors
- (NSError *)failedInResponse:(NSString *)name withCode:(NSUInteger)code;

@end
