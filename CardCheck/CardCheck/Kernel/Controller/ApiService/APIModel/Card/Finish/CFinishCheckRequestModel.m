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

@property (nonatomic) CardImage *backImage;
@property (nonatomic) CardImage *frontImage;

@property (nonatomic, strong) CardReader *reader;
@property (nonatomic, strong) TrackData *trackData;

@end

@implementation CFinishCheckRequestModel

+ (instancetype)requestWithReader:(CardReader *)reader
{
    CFinishCheckRequestModel *model = [CFinishCheckRequestModel new];
    
    [model setReader: reader];
    [model setAppId: [[MandatoryData sharedInstance] appID]];
    
    return model;
}

- (void)setupFakeCardWithImages:(NSArray<CardImage *> *)images
{
    self.backImage = [images lastObject];
    self.frontImage = [images firstObject];
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

- (BOOL)isFakeCard {
    return (self.backImage && self.frontImage)? YES : self.checkResponse.fakeCard;
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
             @"fake_card"       :    @(self.isFakeCard),
             @"front_image_id"  :    @(self.frontImage.ID),
             @"back_image_id"   :    @(self.backImage.ID),
             @"pan3_length"     :    @(0),
             @"pan3_manual"     :    @(YES),
             @"notes"           :    @"notes"
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
