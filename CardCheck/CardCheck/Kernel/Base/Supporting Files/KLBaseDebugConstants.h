//
//  XomCfgConstants.m
//  tryFramework_v1
//
//  Created by itnesPro on 3/29/17.
//  Copyright © 2017 Home. All rights reserved.
//

#ifndef KLBaseDebugConstants_H
#define KLBaseDebugConstants_H

#if 0

#define XT_MAKE_EXEPTION                            assert(0)
#define XT_EXEPTION_NULL(condition)                 NSAssert(condition, @"Must not be NULL")
#define XT_EXEPTION_NOT_MAIN_THREAD                 NSAssert([NSThread isMainThread], @"Must invokes on MainThread")

#else

#define XT_MAKE_EXEPTION                            assert(1)
#define XT_EXEPTION_NULL(condition)                 NSAssert(1, @"Must not be NULL")
#define XT_EXEPTION_NOT_MAIN_THREAD                 NSAssert(1, @"Must invokes on MainThread")

#endif

#define XT_LOG_NOT_IMPLEMENTED                      NSLog(@"Not implemented method - \"%@\"", CURRENT_METHOD)


#define XOM_NOT_DEFINED_ERROR                   999

#define XOM_DATA_ERROR                          300
#define XOM_DATA_SETUP_ERROR                    301

#define XOM_CTR_SETUP_ERROR                     401
#define XOM_CTR_COMPLETE_ERROR                  402
#define XOM_CTR_HANDLE_DATA_ERROR               403

#define XOM_REQUEST_CONNECTION_ERROR            500
#define XOM_REQUEST_COMPLETE_ERROR              502
#define XOM_REQUEST_NOT_EXIST_ERROR             503
#define XOM_REQUEST_CREATE_ERROR                504

#define XOM_RESPONSE_CREATE_ERROR               510
#define XOM_RESPONSE_SETUP_ERROR                511

#define API_RESPONSE_INVALID_SIGN_CODE          4


#define XOM_ERROR_DESCRIPTION                @{[NSNumber numberWithInteger: XOM_NOT_DEFINED_ERROR]                  : @"Not defined error",   \
                                            [NSNumber numberWithInteger: XOM_DATA_ERROR]                            : @"Bad data",   \
                                            [NSNumber numberWithInteger: XOM_DATA_SETUP_ERROR]                      : @"Couldn't setup data with input parameters",   \
                                            [NSNumber numberWithInteger: XOM_CTR_SETUP_ERROR]                       : @"Couldn't setup controller",   \
                                            [NSNumber numberWithInteger: XOM_CTR_COMPLETE_ERROR]                    : @"Couldn't complete the action", \
                                            [NSNumber numberWithInteger: XOM_CTR_HANDLE_DATA_ERROR]                 : @"Couldn't handle the data", \
                                            [NSNumber numberWithInteger: XOM_REQUEST_CONNECTION_ERROR]              : @"Check network connection", \
                                            [NSNumber numberWithInteger: XOM_REQUEST_COMPLETE_ERROR]                : @"Couldn't complete request with reason: ", \
                                            [NSNumber numberWithInteger: XOM_REQUEST_NOT_EXIST_ERROR]               : @"Couldn't find request with response id", \
                                            [NSNumber numberWithInteger: XOM_RESPONSE_CREATE_ERROR]                 : @"Couldn't create response. ResponseId == NULL", \
                                            [NSNumber numberWithInteger: XOM_RESPONSE_SETUP_ERROR]                  : @"Couldn't setup response. Bad input data: ", \
                                            @(API_RESPONSE_INVALID_SIGN_CODE)                  : @"неверная подпись запроса"}

#endif /* XT_Base_Constants_H */
