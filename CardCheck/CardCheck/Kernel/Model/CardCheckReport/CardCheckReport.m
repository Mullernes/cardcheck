//
//  CardImageData.m
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CardCheckReport.h"
#import "CCheckResponseModel.h"

@interface CardCheckReport()

@property (nonatomic, readwrite) long reportID;
@property (nonatomic, readwrite) long long time;

@property (nonatomic, readwrite) long backImgID;
@property (nonatomic, readwrite) long frontImgID;

@property (nonatomic, readwrite) BOOL pan3Manual;
@property (nonatomic, readwrite) NSInteger pan3Length;
@property (nonatomic, strong, readwrite) NSString *pan3;

@property (nonatomic, strong, readwrite) NSArray<CCheckReportData*> *reports;

@end

@implementation CardCheckReport

- (instancetype)initWithCheckResponse:(CCheckResponseModel *)response
{
    self = [super init];
    if (self)
    {
        self.time = response.time;
        self.reportID = response.reportID;

        self.fakeCard = response.fakeCard;
        
        self.backImgID = 0;
        self.frontImgID = 0;
        
        [self setupPan3: [[response.reports firstObject] truncatedPan] manual: NO];
        
        self.notes = @"";
        self.reports = response.reports.copy;
    }
    return self;
}

- (void)setupPan3:(NSString *)value manual:(BOOL)manual
{
    self.pan3Manual = manual;
    self.pan3Length = value.length;
    
    if (value.length) {
        _pan3 = [DEMO_PAN_ZERO stringByReplacingCharactersInRange: NSMakeRange(0, value.length) withString: value];
    }
    else {
        _pan3 = DEMO_PAN_ZERO;
    }
}

- (void)setupWithCardImage:(CardImage *)image
{
    if (self.frontImgID == 0)
        self.frontImgID = image.ID;
    else if (self.backImgID == 0)
        self.backImgID = image.ID;
}

- (void)setupWithManualPan:(NSString *)pan
{
    [self setupPan3: pan manual: YES];
}

@end
