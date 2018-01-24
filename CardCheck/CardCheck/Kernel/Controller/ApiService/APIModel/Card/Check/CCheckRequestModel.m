//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CCheckRequestModel.h"

@interface CCheckRequestModel()

@property (nonatomic) long appId;
@property (nonatomic, strong) NSString *appVersion;

@property (nonatomic, strong) CardReader *reader;
@property (nonatomic, strong) AesTrackData *trackData;

@end

@implementation CCheckRequestModel

+ (instancetype)requestWithReader:(CardReader *)reader
{
    CCheckRequestModel *model = [CCheckRequestModel new];
    
    [model setAppId: [[MandatoryData sharedInstance] appID]];
    [model setAppVersion: [[CurrentDevice sharedInstance] appVersion]];
    
    [model setReader: reader];
    
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        long long time = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        [self setupWithTime: time];
    }
    return self;
}

- (AesTrackData *)trackData {
    return self.reader.trackData;
}

- (NSDictionary *)parameters
{
    return @{@"time"            :   @(self.time),
             @"cardreader_type" :   @(self.reader.type),
             @"cardreader_id"   :   self.reader.deviceID,
             @"app_id"          :   @(self.appId),
             @"track1_length"   :   @(self.trackData.tr1Length),
             @"track1_code"     :   @(self.trackData.tr1Code),
             @"track2_length"   :   @(self.trackData.tr2Length),
             @"track2_code"     :   @(self.trackData.tr2Code),
             @"battery_low"     :   @(self.reader.lowBattery),
             @"app_version"     :   self.appVersion,
             @"data"            :   self.trackData.cipherHexData
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
