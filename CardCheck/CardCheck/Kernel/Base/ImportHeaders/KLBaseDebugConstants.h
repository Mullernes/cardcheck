//
//  XomCfgConstants.m
//  tryFramework_v1
//
//  Created by itnesPro on 3/29/17.
//  Copyright © 2017 Home. All rights reserved.
//

#ifndef KLBaseDebugConstants_H
#define KLBaseDebugConstants_H

#if 1

#define XT_MAKE_EXEPTION                            assert(0)
#define XT_EXEPTION_NULL(condition)                 NSAssert(condition, @"Must not be NULL")
#define XT_EXEPTION_NOT_MAIN_THREAD                 NSAssert([NSThread isMainThread], @"Must invokes on MainThread")

#else

#define XT_MAKE_EXEPTION                            assert(1)
#define XT_EXEPTION_NULL(condition)                 NSAssert(1, @"Must not be NULL")
#define XT_EXEPTION_NOT_MAIN_THREAD                 NSAssert(1, @"Must invokes on MainThread")

#endif

#define XT_LOG_NOT_IMPLEMENTED                      NSLog(@"Not implemented method - \"%@\"", CURRENT_METHOD)

#endif /* XT_Base_Constants_H */
