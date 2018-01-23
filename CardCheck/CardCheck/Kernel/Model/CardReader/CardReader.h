//
//  CardReader.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface CardReader : KLBaseModel

@property (nonatomic, readonly) NSUInteger type;
@property (nonatomic, readonly) BOOL lowBattery;

@property (nonatomic, strong, readonly) NSString *deviceID;
@property (nonatomic, strong, readonly) NSString *customID;

@property (nonatomic, getter=isPlugged) BOOL plugged;

@property (nonatomic, strong) AesTrackData *trackData;

+ (instancetype)demoData;
+ (instancetype)emptyData;

- (BOOL)isReady;
- (void)setupWithDeviceID:(NSString *)deviceID;
- (void)setupWithCustomID:(NSString *)customID;

@end
