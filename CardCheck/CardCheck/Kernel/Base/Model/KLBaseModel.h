//
//  STBaseModel.h
//  DemoTelephony
//
//  Created by itnesPro on 11/17/17.
//  Copyright © 2017 SafeUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLBaseModel : NSObject

@property (nonatomic, readonly, getter=lastFailErr) NSError *failErr;
@property (nonatomic, readonly, getter=lastWarnErr) NSError *warnErr;

@property (nonatomic, strong) NSMutableArray<NSError *> *warnErrors;
@property (nonatomic, strong) NSMutableArray<NSError *> *failErrors;

#pragma mark - Working
- (BOOL)isCorrect;
- (void)onInfo:(NSString *)format, ...;
- (void)onSuccess:(NSString *)format, ...;

#pragma mark - Errors
- (NSError *)warnedInMethod:(NSString *)method
                 withReason:(NSString *)format, ...;

- (NSError *)failedInMethod:(NSString *)method
                 withReason:(NSString *)format, ...;

- (NSError *)errorWithCode:(NSNumber *)code
                    method:(NSString *)method
                    reason:(NSString *)reason;

- (void)setupWithFailed:(NSError *)error;

#pragma mark - Debug
- (NSString *)currentClass;
- (NSString *)debugDescription;

@end

