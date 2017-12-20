//
//  KLBaseController.m
//  tryFramework_v1
//
//  Created by girya on 3/2/17.
//  Copyright © 2017 Home. All rights reserved.
//

#define LOG_KEY_INFO @"-INFO: "
#define LOG_KEY_SUCCESS @"-SUCCESS: "
#define LOG_KEY_WARNING @"-WARNING: "
#define LOG_KEY_FAILURE @"-FAILURE: "

#import "KLBaseController.h"
//#import "Logger.h"

@implementation KLBaseController

#pragma mark - Logging

- (void)onInfo:(NSString *)format, ... {
    @try {
        va_list ap;
        va_start (ap, format);
        
        if (![format hasSuffix: @"\n"])
            format = [format stringByAppendingString: @"\n"];
        
        NSString *logInfo = [[NSString alloc] initWithFormat: format arguments: ap];
        va_end (ap);
        
        NSString *allInfo = [NSString stringWithFormat: @"%@%@%@", [self currentClass], LOG_KEY_INFO, logInfo];
        [self logged: allInfo];
        
    } @catch (NSException *exception) {
        NSLog(@"exception = %@", exception.debugDescription);
    }
}

- (void)onSuccess:(NSString *)format, ... {
    @try {
        va_list ap;
        va_start (ap, format);
        
        if (![format hasSuffix: @"\n"])
            format = [format stringByAppendingString: @"\n"];
        
        NSString *logInfo = [[NSString alloc] initWithFormat: format arguments: ap];
        va_end (ap);
        
        NSString *allInfo = [NSString stringWithFormat: @"%@%@%@", [self currentClass], LOG_KEY_SUCCESS, logInfo];
        [self logged: allInfo];
        
    } @catch (NSException *exception) {
        NSLog(@"exception = %@", exception.debugDescription);
    }
}

- (void)onWarning:(NSError *)error
{
    NSString *allInfo = [NSString stringWithFormat: @"%@%@%@", [self currentClass], LOG_KEY_WARNING, [error.userInfo.allValues firstObject]];
    [self logged: allInfo];
}

- (void)onFailure:(NSError *)error
{
    NSString *allInfo = [NSString stringWithFormat: @"%@%@%@", [self currentClass], LOG_KEY_FAILURE, [error.userInfo.allValues firstObject]];
    [self logged: allInfo];
}

- (void)onFailureIfNeeded:(NSError *)error
{
    if (error) {
        [self onFailure: error];
    }
}

- (void)logged:(NSString *)log
{
    //[[Logger sharedInstance] loggedAll: log];
}

#pragma mark - Making errors

- (NSError *)error:(NSString *)info
{
    NSError *error = [NSError errorWithDomain: [self currentClass] code:0 userInfo:@{NSLocalizedDescriptionKey : info?info:@"undefined"}];
    return error;
}

- (NSError *)errorWithComment:(NSString *)comment
{
    NSInteger code = 0;
    NSString *logInfo = nil;
    
    NSError *error = [NSError errorWithDomain: [self currentClass] code: code userInfo: @{NSLocalizedDescriptionKey : logInfo?logInfo:@"undefined info"}];
    return error;
}

- (NSError *)errorCallStartWithComment:(NSString *)comment
{
    NSInteger code = [comment isEqualToString: @"sraka"]? XOM_NOT_DEFINED_ERROR : XOM_NOT_DEFINED_ERROR;
    NSString *logInfo = (code == XOM_NOT_DEFINED_ERROR) ? [NSString stringWithFormat: @"Not defined error: %@", comment] : [XOM_ERROR_DESCRIPTION objectForKey: [NSNumber numberWithInteger: code]];
    
    NSError *error = [NSError errorWithDomain: [self currentClass] code: code userInfo: @{NSLocalizedDescriptionKey : logInfo?logInfo:@"undefined info"}];
    return error;
}

- (NSError *)errorCallAnswerWithComment:(NSString *)comment
{
    NSInteger code = [comment isEqualToString: @"sraka"]? XOM_NOT_DEFINED_ERROR : XOM_NOT_DEFINED_ERROR;
    NSString *logInfo = (code == XOM_NOT_DEFINED_ERROR) ? [NSString stringWithFormat: @"Not defined error: %@", comment] : [XOM_ERROR_DESCRIPTION objectForKey: [NSNumber numberWithInteger: code]];
    
    NSError *error = [NSError errorWithDomain: [self currentClass] code: code userInfo: @{NSLocalizedDescriptionKey : logInfo?logInfo:@"undefined info"}];
    return error;
}

- (NSError *)errorWithCode:(NSInteger)code format:(NSString *)format, ...
{
    va_list ap;
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *info = [[NSString alloc] initWithFormat: format arguments: ap];
    NSString *logInfo = [NSString stringWithFormat:@"%@ %@", [XOM_ERROR_DESCRIPTION objectForKey: [NSNumber numberWithInteger: code]], info];
    va_end (ap);
    
    NSError *error = [NSError errorWithDomain: [self currentClass] code: code userInfo: @{NSLocalizedDescriptionKey : logInfo?logInfo:@"undefined info"}];

    return error;
}

- (NSError *)completionError:(NSString *)method andReason:(NSString *)format, ...
{
    NSNumber *code = [NSNumber numberWithInteger: XOM_CTR_COMPLETE_ERROR];
    
    va_list ap;
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *reason = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
    
    return [self errorWithCode: code method: method reason: reason];
}

- (NSError *)connectionError:(NSString *)method
{
    NSNumber *code = [NSNumber numberWithInteger: XOM_REQUEST_CONNECTION_ERROR];
    return [self errorWithCode: code method: method reason: nil];
}

- (NSError *)errorWithCode:(NSNumber *)code method:(NSString *)method reason:(NSString *)reason
{
    //1
    NSString *prefix = [XOM_ERROR_DESCRIPTION objectForKey: code];
    
    //3
    NSString *localizedInfo = [NSString stringWithFormat: @"Prefix: %@ \n Method: %@ \n Reason: %@", prefix, method, reason];
    
    //4
    NSError *error = [NSError errorWithDomain: [self currentClass]
                                         code: code.integerValue
                                     userInfo: @{NSLocalizedDescriptionKey : localizedInfo}];
    return error;
}

#pragma mark - Debug 

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", self];
}

@end
