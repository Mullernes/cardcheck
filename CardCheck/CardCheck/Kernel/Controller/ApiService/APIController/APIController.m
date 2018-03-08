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
@property (nonatomic, strong) AFHTTPSessionManager *uploadManager;

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

- (AFHTTPSessionManager *)manager {
    if (nil == _manager) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: cfg];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [_manager.requestSerializer setValue: @"application/json; charset=utf-8"
                          forHTTPHeaderField: @"Content-Type"];
    }
    
    return _manager;
}

- (AFHTTPSessionManager *)uploadManager {
    if (nil == _uploadManager) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        _uploadManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: cfg];
        [_uploadManager.requestSerializer setValue: @"multipart/form-data"
                                forHTTPHeaderField: @"Content-Type"];
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
    if ([[ReaderController sharedInstance] isStaging]) {
        return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_CARD_CHECK_TARGET];
    }
    else {
        return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_CARD_TEST_TARGET];
    }
}

- (NSString *)cFinishCheckUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_CARD_CHECK_COMPLETE_TARGET];
}

- (NSString *)cUploadImagekUrl
{
    return [NSString stringWithFormat:@"%@%@", API_BASE_URL, API_CARD_UPLOAD_IMAGE_TARGET];
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
    NSLog(@"request = %@", request.parameters);
    
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
             CCheckResponseModel *response = [CCheckResponseModel responseWithRawData: responseObject];
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

- (void)sendCFinishCheckRequest:(CFinishCheckRequestModel *)request
                 withCompletion:(CFinishCheckResponseHandler)handler
{
    NSLog(@"request = %@", request.parameters);
    
    //1
    NSString *sign = [self.crpController calcSignature1: [request jsonData]];
    if ([request setupWithSignature: sign]) {
        //2
        [self.manager.requestSerializer setValue: request.signature
                              forHTTPHeaderField: @"Content-Hmac"];
        //3
        [self.manager POST: [self cFinishCheckUrl]
                parameters: [request parameters]
                  progress: nil
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             CFinishCheckResponseModel *response = [CFinishCheckResponseModel responseWithRawData: responseObject];
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

- (void)uploadImageRequest:(CUploadRequestModel *)request
            withCompletion:(CUploadResponseHandler)handler
{
    NSLog(@"request = %@", [request debugDescription]);
    
    //Handlers
    void (^constructionHandler)(id <AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: request.cardImg.data
                                    name: request.name
                                fileName: request.fileName
                                mimeType: request.mimeType];
    };

    void (^uploadProgressHandler)(NSProgress *) = ^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"completed fraction = %f", uploadProgress.fractionCompleted);
    };

    void (^completionHandler)(NSURLResponse *, id, NSError *) = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
    {
        if (error) {
            handler(nil, error);
        } else {
            CUploadResponseModel *response = [CUploadResponseModel responseWithRawData: responseObject];
            if (response.isCorrect) {
                handler(response, nil);
            }
            else {
                handler(response, response.failErr);
            }
        }
    };

    //Request
    NSError *err = nil;
    NSMutableURLRequest *urlRequest = [[AFHTTPRequestSerializer serializer]
                                    multipartFormRequestWithMethod: @"POST"
                                    URLString: [self cUploadImagekUrl]
                                    parameters: request.parameters
                                    constructingBodyWithBlock: constructionHandler
                                    error: &err];

    NSURLSessionUploadTask *task = [self.uploadManager uploadTaskWithStreamedRequest: urlRequest
                                                                            progress: uploadProgressHandler
                                                                   completionHandler: completionHandler];
    [task resume];
}

@end

