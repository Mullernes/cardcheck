//
//  MandatoryData.m
//  CardCheck
//
//  Created by itnesPro on 1/8/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#define     kMandatoryData  @"kMandatoryData"
#define     kAppID          @"kAppID"
#define     kDeviceID       @"kDeviceID"
#define     kAppDataKey     @"kAppDataKey"
#define     kAppCommKey     @"kAppCommKey"

#import "MandatoryData.h"

@interface MandatoryData()

@property (nonatomic, readwrite) BOOL exist;

//@property (nonatomic, readwrite) long appID;
//@property (nonatomic, readwrite) NSString *deviceID;    
//@property (nonatomic, readwrite) NSString *appDataKey;
//@property (nonatomic, readwrite) NSString *appCommKey;

@end

@implementation MandatoryData

#pragma mark - Init
+ (instancetype)sharedInstance
{
    static MandatoryData *mData;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mData = [[self alloc] init];
    });
    return mData;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        NSDictionary *data = [USER_DEFAULTS objectForKey: kMandatoryData];
        if (data) {
            self.exist = YES;
            
            self.appID = [[USER_DEFAULTS objectForKey: kAppID] longValue];
            self.deviceID = [USER_DEFAULTS objectForKey: kDeviceID];
            self.appDataKey =  [USER_DEFAULTS objectForKey: kAppDataKey];
            self.appCommKey =  [USER_DEFAULTS objectForKey: kAppCommKey];
        }
        else {
            self.exist = NO;
        }
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

- (void)save
{
    NSDictionary *data = @{kAppID       : @(self.appID),
                           kDeviceID    : self.deviceID,
                           kAppDataKey  : self.appDataKey,
                           kAppCommKey  : self.appCommKey};

    [USER_DEFAULTS setObject: data forKey: kMandatoryData];
    [USER_DEFAULTS synchronize];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; data = %@", self, [USER_DEFAULTS objectForKey: kMandatoryData]];
}

@end
