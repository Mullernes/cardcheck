//
//  KLBaseController.h
//  tryFramework_v1
//
//  Created by girya on 3/2/17.
//  Copyright © 2017 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLBaseController : NSObject

#pragma mark - Logging
- (void)onInfo:(NSString *)format, ...;
- (void)onSuccess:(NSString *)format, ...;

- (void)onWarning:(NSError *)error;
- (void)onFailure:(NSError *)error;
- (void)onFailureIfNeeded:(NSError *)error;

- (void)logged:(NSString *)log;

#pragma mark - Making errors
- (NSError *)error:(NSString *)info;
- (NSError *)errorCallStartWithComment:(NSString *)comment;
- (NSError *)errorCallAnswerWithComment:(NSString *)comment;

- (NSError *)errorWithCode:(NSInteger)code
                    format:(NSString *)format, ...;

- (NSError *)completionError:(NSString *)method
                   andReason:(NSString *)format, ...;

- (NSError *)connectionError:(NSString *)method;

#pragma mark - Debug 
- (NSString *)currentClass;
- (NSString *)debugDescription;

@end
