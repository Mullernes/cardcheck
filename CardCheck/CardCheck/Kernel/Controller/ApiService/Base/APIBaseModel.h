//
//  APIBaseModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface APIBaseModel : KLBaseModel

@property (nonatomic, readonly) long long time;
@property (nonatomic, strong, readonly) NSString *signature;
@property (nonatomic, strong, readonly) APIBaseModel *request;

- (instancetype)initWithRawData:(NSDictionary *)data;

#pragma mark - Working
- (NSData *)jsonData;
- (NSString *)jsonString;
- (NSDictionary *)parameters;

- (void)setupWithTime:(long long)time;
- (BOOL)setupWithSignature:(NSString *)sign;
- (void)setupWithRequest:(APIBaseModel *)request;

#pragma mark - Errors
- (NSError *)failedInResponse:(NSString *)name withCode:(NSInteger)code;

@end
