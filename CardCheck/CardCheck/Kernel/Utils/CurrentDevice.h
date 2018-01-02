//
//  XomDevice.h
//  SafeUMHD
//
//  Created by girya on 9/15/15.
//  Copyright © 2015 Nestor Melnyk. All rights reserved.
//


#import "SDVersion.h"

@interface CurrentDevice : NSObject

@property (nonatomic, readonly) NSString *uid;

@property (nonatomic, readonly) NSString *deviceName;
@property (nonatomic, readonly) NSString *deviceModel;

@property (nonatomic, readonly) NSString *osVesrion;
@property (nonatomic, readonly) NSString *appVersion;
@property (nonatomic, readonly) NSString *appShortVersion;
@property (nonatomic, readonly) NSString *appBuildVersion;

@property (nonatomic, readonly) NSString *bundleIdnf;

#pragma mark - Init
+ (instancetype)sharedInstance;

#pragma mark - Working Methods
- (NSString *)generalInfo;

#pragma mark - Utils
- (NSString *)localeIdnf;
- (NSInteger)localTimeZone;

@end
