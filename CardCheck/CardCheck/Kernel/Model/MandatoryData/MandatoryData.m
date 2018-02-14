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
#define     kStageMode      @"kStageMode"

#import "MandatoryData.h"

@interface MandatoryData()

@property (nonatomic, readwrite) BOOL exist;

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
        if (data)
        {
            self.exist = YES;
            
            self.deviceID = [data objectForKey: kDeviceID];
            self.appDataKey =  [data objectForKey: kAppDataKey];
            self.appCommKey =  [data objectForKey: kAppCommKey];
            self.appID = [[data objectForKey: kAppID] longValue];
            self.stageMode = [[data objectForKey: kStageMode] boolValue];
        }
        else {
            self.exist = NO;
        }
        
        [self onSuccess: @"%@ inited with %@", CURRENT_CLASS, [self debugDescription]];
    }
    return self;
}

- (void)save
{
    self.exist = YES;
    
    NSDictionary *data = @{kAppID       : @(self.appID),
                           kDeviceID    : self.deviceID,
                           kAppDataKey  : self.appDataKey,
                           kAppCommKey  : self.appCommKey,
                           kStageMode   : @(self.stageMode)
                           };

    [USER_DEFAULTS setObject: data forKey: kMandatoryData];
    [USER_DEFAULTS synchronize];
}

- (void)clean
{
    self.exist = NO;
    
    [USER_DEFAULTS removeObjectForKey: kMandatoryData];
    [USER_DEFAULTS synchronize];
    
    [self onSuccess: @"%@ => %@", CURRENT_CLASS, [self debugDescription]];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; \n data = %@ \n\n", self, [USER_DEFAULTS objectForKey: kMandatoryData]];
}

@end
