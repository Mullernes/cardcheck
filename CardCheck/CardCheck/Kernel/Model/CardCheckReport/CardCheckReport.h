//
//  CardImageData.h
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@class CCheckResponseModel, CCheckReportData;
@interface CardCheckReport : KLBaseModel

@property (nonatomic, readonly) long reportID;
@property (nonatomic, readonly) long long time;

@property (nonatomic, getter=isFake) BOOL fakeCard;

@property (nonatomic, readonly) long backImgID;
@property (nonatomic, readonly) long frontImgID;

@property (nonatomic, readonly) BOOL pan3Manual;
@property (nonatomic, readonly) NSInteger pan3Length;
@property (nonatomic, strong, readonly) NSString *pan3Hex;

@property (nonatomic, strong) NSString *notes;

@property (nonatomic, strong, readonly) NSArray<CCheckReportData*> *reports;

- (instancetype)initWithCheckResponse:(CCheckResponseModel *)response;

- (void)setupWithCardImage:(CardImage *)image;
- (void)setupWithManualPan:(NSString *)pan;

@end
