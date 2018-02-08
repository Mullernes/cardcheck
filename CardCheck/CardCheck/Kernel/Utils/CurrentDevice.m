//
//  Device.m
//  SafeUMHD
//
//  Created by girya on 9/15/15.
//  Copyright © 2015 Nestor Melnyk. All rights reserved.
//

#import "CurrentDevice.h"

@interface CurrentDevice()

@property (nonatomic, readwrite) NSString *uid;
@property (nonatomic, readwrite) NSString *deviceName;
@property (nonatomic, readwrite) NSString *deviceModel;

@property (nonatomic, readwrite) NSString *osVesrion;
@property (nonatomic, readwrite) NSString *appVersion;
@property (nonatomic, readwrite) NSString *appShortVersion;
@property (nonatomic, readwrite) NSString *appBuildVersion;

@property (nonatomic, readwrite) NSString *bundleIdnf;

@end

@implementation CurrentDevice

#pragma mark - Init
+ (instancetype)sharedInstance
{
    static CurrentDevice *_device;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _device = [[self alloc] init];
    });
    return _device;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.deviceName = [[UIDevice currentDevice] name];
        self.deviceModel = [SDiOSVersion deviceNameString];
        
        self.osVesrion = [self iosVersion];
        self.appShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        self.appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
        self.appVersion = [NSString stringWithFormat:@"%@.%@", self.appShortVersion, self.appBuildVersion];
        
        self.bundleIdnf = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleIdentifier"];
    }
    return self;
}

#pragma mark - Working Methods

- (NSString *)generalInfo {
    return [NSString stringWithFormat:@"%@,%@, OS: %@, UUID: %@", self.deviceName, self.deviceModel, self.osVesrion, self.uid];
}

#pragma mark - Utils

- (NSString *)localeIdnf
{
    NSString *value = [[NSLocale currentLocale] localeIdentifier];
    return value;
}

- (NSInteger)localTimeZone
{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    int hours = (int)([timeZone secondsFromGMT] / 3600);
    
    return hours;
}

- (NSString *)iosVersion
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([[version componentsSeparatedByString:@"."] count] < 3)
        version = [NSString stringWithFormat:@"ios_%@.0", version];
    else
        version = [NSString stringWithFormat:@"ios_%@", version];
    
    return version;
}

#pragma mark - Debug methods

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@, devUid = %@; devName = %@; osVer = %@; \n\n", self, self.uid, self.deviceName, self.osVesrion];
}

@end
