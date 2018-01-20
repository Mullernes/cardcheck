//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CFinishCheckRequestModel.h"

@interface CFinishCheckRequestModel()

@property (nonatomic) long appId;

@property (nonatomic, strong) CardReaderData *reader;
@property (nonatomic, strong) AesTrackData *trackData;

@end

@implementation CFinishCheckRequestModel

+ (instancetype)requestWithReader:(CardReaderData *)reader
{
    CFinishCheckRequestModel *model = [CFinishCheckRequestModel new];
    
    [model setReader: reader];
    [model setAppId: [[MandatoryData sharedInstance] appID]];
    
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
             @"data"            :   self.trackData.cipherHexData,
             
             @"report_id"       :    @(self.checkResponse.reportID),
             @"fake_card"       :    @(self.checkResponse.fakeCard),
             @"front_image_id"  :    @(0),
             @"back_image_id"   :    @(0),
             @"pan3_length"     :    @(0),
             @"pan3_manual"     :    @(YES),
             @"notes"           :    @"notes"
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
