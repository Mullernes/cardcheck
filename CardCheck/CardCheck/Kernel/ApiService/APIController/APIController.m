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

#pragma mark - Working

- (NSString *)authRequestUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_AUTH_TARGET];
}

- (void)sendAuthRequest:(AuthRequestModel *)model withCompletion:(AuthResponseHandler)handler
{
    //1
    NSInteger signValue = [self.crpController hotpWithData: [model jsonData]
                                                 andSecret: DEMO_CUSTOM_ID];
    
    [model setSignature: [NSString stringWithFormat:@"%li", signValue]];
    
    //2
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: cfg];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue: @"application/json; charset=utf-8"
                     forHTTPHeaderField: @"Content-Type"];
    [manager.requestSerializer setValue: model.signature
                     forHTTPHeaderField: @"Content-Hmac"];
    
    [manager POST: [self authRequestUrl]
       parameters: [model parameters]
         progress: nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              AuthResponseModel *model = [AuthResponseModel responseWithRawData: responseObject];
              if (model.isCorrect) {
                  handler(model, nil);
              }
              else {
                  handler(nil, model.failErr);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              handler(nil, error);
          }];
}

@end

