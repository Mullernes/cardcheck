//
//  APIController.m
//  CardCheck
//
//  Created by itnesPro on 12/27/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIController.h"

@interface APIController()

@property (nonatomic, strong) CryptoController *crpController;
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation APIController

#pragma mark - Init

+ (instancetype)sharedInstance
{
    static APIController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
    });
    return controller;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        self.crpController = [CryptoController sharedInstance];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

- (void)initSessionManager {
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: cfg];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setValue: @"application/json; charset=utf-8"
                          forHTTPHeaderField: @"Content-Type"];
}

- (AFHTTPSessionManager *)manager {
    if (nil == _manager) {
        [self initSessionManager];
    }
    
    return _manager;
}

#pragma mark - Working

- (NSString *)authRequestUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_AUTH_TARGET];
}

- (NSString *)deviceInitRequestUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_DEV_INIT_TARGET];
}

- (void)sendAuthRequest:(AuthRequestModel *)request
         withCompletion:(AuthResponseHandler)handler
{
    //1
    NSNumber *sign = [self.crpController hotpWithPlainData: [request jsonData]
                                                 andHexKey: request.reader.customID];
    if ([request setupWithSignature: sign]) {
        //2
        [self.manager.requestSerializer setValue: request.signature
                              forHTTPHeaderField: @"Content-Hmac"];
        //3
        [self.manager POST: [self authRequestUrl]
                parameters: [request parameters]
                  progress: nil
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
                    AuthResponseModel *response = [AuthResponseModel responseWithRawData: responseObject];
                  if (response.isCorrect) {
                      [response setupWithRequest: request];
                      handler(response, nil);
                  }
                  else {
                      handler(nil, response.failErr);
                  }
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  handler(nil, error);
              }];
    }
    else {
        //TODO: make error
    }
}

- (void)sendDevInitRequest:(DevInitRequestModel *)request
            withCompletion:(DevInitResponseHandler)handler
{
    //1
    NSNumber *sign = [self.crpController hotpWithPlainData: [request jsonData]
                                                 andHexKey: request.reader.customID];
    if ([request setupWithSignature: sign]) {
        //2
        [self.manager.requestSerializer setValue: request.signature
                              forHTTPHeaderField: @"Content-Hmac"];
        //3
        [self.manager POST: [self deviceInitRequestUrl]
                parameters: [request parameters]
                  progress: nil
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
                       DevInitResponseModel *response = [DevInitResponseModel responseWithRawData: responseObject];
                       if (response.isCorrect) {
                           [response setupWithRequest: request];
                           handler(response, nil);
                       }
                       else {
                           handler(nil, response.failErr);
                       }
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       handler(nil, error);
                   }];
    }
    else {
        //TODO: make error
    }
}

@end

