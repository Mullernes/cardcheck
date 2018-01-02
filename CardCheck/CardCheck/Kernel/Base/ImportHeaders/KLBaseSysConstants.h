//
//  SocketDefines.h
//  SafeUMHD
//
//  Created by girya on 9/8/15.
//  Copyright (c) 2015 Nestor Melnyk. All rights reserved.
//

#ifndef KLBaseSysConstants_H
#define KLBaseSysConstants_H


#define USER_DEFAULTS                       [NSUserDefaults standardUserDefaults]
#define APPLICATION_STATE                   [[UIApplication sharedApplication] applicationState]

#define CURRENT_CLASS                       NSStringFromClass([self class])
#define CURRENT_METHOD                      NSStringFromSelector(_cmd)

#define IOS_6_1                             @"6.1"
#define IOS_7_0                             @"7.0"
#define IOS_8_0                             @"8.0"
#define IOS_9_0                             @"9.0"
#define IOS_10_0                            @"10.0"
#define IOS_11_0                            @"11.0"

#define IS_IPHONE_4                                 ([[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_GREATER_THAN_5                    ([[UIScreen mainScreen] bounds].size.height > 568.0)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#endif /* XT_App_Constants_H */
