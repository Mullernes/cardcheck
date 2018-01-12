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

- (NSString *)authUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_AUTH_TARGET];
}

- (NSString *)initializationUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_DEV_INIT_TARGET];
}

- (NSString *)cCheckUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_CARD_CHECK_TARGET];
}

- (void)sendAuthRequest:(AuthRequestModel *)request
         withCompletion:(AuthResponseHandler)handler
{
    //1
    NSString *sign = [self.crpController calcSignature2: [request jsonData]];
    if ([request setupWithSignature: sign]) {
        //2
        [self.manager.requestSerializer setValue: request.signature
                              forHTTPHeaderField: @"Content-Hmac"];
        //3
        [self.manager POST: [self authUrl]
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
        XT_MAKE_EXEPTION;
    }
}

- (void)sendDevInitRequest:(InitRequestModel *)request
            withCompletion:(DevInitResponseHandler)handler
{
    //1
    NSString *sign = [self.crpController calcSignature2: [request jsonData]];
    if ([request setupWithSignature: sign]) {
        //2
        [self.manager.requestSerializer setValue: request.signature
                              forHTTPHeaderField: @"Content-Hmac"];
        //3
        [self.manager POST: [self initializationUrl]
                parameters: [request parameters]
                  progress: nil
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
                       InitResponseModel *response = [InitResponseModel responseWithRawData: responseObject];
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
        XT_MAKE_EXEPTION;
    }
}

- (void)sendCCheckRequest:(CCheckRequestModel *)request
           withCompletion:(CCheckResponseHandler)handler
{
    //1
    NSString *sign = [self.crpController calcSignature1: [request jsonData]];
    if ([request setupWithSignature: sign]) {
        //2
        [self.manager.requestSerializer setValue: request.signature
                              forHTTPHeaderField: @"Content-Hmac"];
        //3
        [self.manager POST: [self cCheckUrl]
                parameters: [request parameters]
                  progress: nil
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             handler(responseObject, nil);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             handler(nil, error);
         }];
    }
    else {
        XT_MAKE_EXEPTION;
    }
}

@end

