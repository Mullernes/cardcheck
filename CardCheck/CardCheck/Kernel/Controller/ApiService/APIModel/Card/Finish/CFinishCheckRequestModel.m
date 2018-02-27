//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CFinishCheckRequestModel.h"
#import "CardCheckReport.h"

@interface CFinishCheckRequestModel()

@property (nonatomic) long appId;
@property (nonatomic, strong) CardReader *reader;
@property (nonatomic, strong) TrackData *trackData;
@property (nonatomic, strong) CardCheckReport *report;

@end

@implementation CFinishCheckRequestModel

+ (instancetype)requestWithReader:(CardReader *)reader
{
    CFinishCheckRequestModel *model = [CFinishCheckRequestModel new];
    
    [model setReader: reader];
    [model setAppId: [[MandatoryData sharedInstance] appID]];
    
    return model;
}

- (void)setupWithReport:(CardCheckReport *)report;
{
    self.report = report;
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

- (TrackData *)trackData {
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
             
             @"report_id"       :    @(self.report.reportID),
             @"fake_card"       :    @(self.report.isFake),
             @"front_image_id"  :    @(self.report.frontImgID),
             @"back_image_id"   :    @(self.report.backImgID),
             @"pan3_length"     :    @(self.report.pan3Length),
             @"pan3_manual"     :    @(self.report.pan3Manual),
             @"notes"           :    self.report.notes
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
