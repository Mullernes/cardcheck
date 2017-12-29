//
//  STBaseModel.m
//  DemoTelephony
//
//  Created by itnesPro on 11/17/17.
//  Copyright © 2017 SafeUM. All rights reserved.
//

#import "KLBaseModel.h"

#define LOG_KEY_INFO        @"-INFO:\n"
#define LOG_KEY_SUCCESS     @"-CORRECT_MODEL:\n"
#define LOG_KEY_WARNING     @"-WARNING: CODE = "
#define LOG_KEY_FAILURE     @"-FAILURE: CODE = "

#define UNDEFINED_INFO      @"undefined error"

#define MODEL_WARNING_ERROR     300
#define MODEL_FAILURE_ERROR     301

@interface KLBaseModel()

@property (nonatomic, readwrite) NSError *failErr;
@property (nonatomic, readwrite) NSError *warnErr;

@end


@implementation KLBaseModel

#pragma mark - Accessors

- (void)setFailErr:(NSError *)failErr
{
    if (failErr) {
        _failErr = failErr;
        
        [self.failErrors addObject: failErr];
        [self onFailure: failErr];
    }
}

- (void)setWarnErr:(NSError *)warnErr
{
    if (warnErr) {
        _failErr = warnErr;
        
        [self.warnErrors addObject: warnErr];
        [self onWarning: warnErr];
    }
}

- (NSMutableArray<NSError *> *)failErrors {
    if (nil == _failErrors)
        _failErrors = [NSMutableArray array];
    
    return _failErrors;
}

- (NSMutableArray<NSError *> *)warnErrors {
    if (nil == _warnErrors)
        _warnErrors = [NSMutableArray array];
    
    return _warnErrors;
}

#pragma mark - Working

- (BOOL)isCorrect
{
    return ([self.failErrors count] == 0);
}

- (void)onInfo:(NSString *)format, ...
{
    va_list ap;
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *logInfo = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
    
    NSLog(@"%@%@%@", [self currentClass], LOG_KEY_INFO, logInfo);
}

- (void)onSuccess:(NSString *)format, ...
{
    va_list ap;
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *logInfo = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
    
    NSLog(@"%@%@%@", [self currentClass], LOG_KEY_SUCCESS, logInfo);
}

- (void)onWarning:(NSError *)error
{
    NSLog(@"%@%@%li; %@", [self currentClass], LOG_KEY_WARNING, (long)error.code, [error.userInfo.allValues firstObject]);
}

- (void)onFailure:(NSError *)error
{
    NSLog(@"%@%@%li; %@", [self currentClass], LOG_KEY_FAILURE, (long)error.code, [error.userInfo.allValues firstObject]);
}

#pragma mark - Errors

- (NSError *)warnedInMethod:(NSString *)method withReason:(NSString *)format, ...
{
    //1
    NSNumber *code = [NSNumber numberWithInteger: MODEL_WARNING_ERROR];
    
    //2
    va_list ap;
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *reason = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
    
    //3
    NSError *err = [self errorWithCode: code method: method reason: reason];
    [self setWarnErr: err];
    
    return err;
}

- (NSError *)failedInMethod:(NSString *)method withReason:(NSString *)format, ...
{
    //1
    NSNumber *code = [NSNumber numberWithInteger: MODEL_FAILURE_ERROR];
    
    //2
    va_list ap;
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *reason = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
    
    //3
    NSError *err = [self errorWithCode: code method: method reason: reason];
    [self setFailErr: err];
    
    return err;
}

- (NSError *)errorWithCode:(NSNumber *)code method:(NSString *)method reason:(NSString *)reason
{
    NSString *prefix = [XOM_ERROR_DESCRIPTION objectForKey: code];
    NSString *localizedInfo = [NSString stringWithFormat:
                               @"Prefix: %@ \n Method: %@ \n Reason: %@", prefix, method, reason];
    
    NSError *error = [NSError errorWithDomain: [self currentClass]
                                         code: code.integerValue
                                     userInfo: @{NSLocalizedDescriptionKey : localizedInfo}];
    return error;
}

- (void)setupWithFailed:(NSError *)error
{
    [self setFailErr: error];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", self];
}

@end
