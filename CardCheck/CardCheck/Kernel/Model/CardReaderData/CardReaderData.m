//
//  CardReader.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CardReaderData.h"

@interface CardReaderData()

@property (nonatomic, readwrite) NSUInteger type;
@property (nonatomic, readwrite) BOOL lowBattery;
@property (nonatomic, readwrite) NSString *deviceID;
@property (nonatomic, readwrite) NSString *customID;

@end

@implementation CardReaderData

+ (instancetype)demoData {
    CardReaderData *reader = [[CardReaderData alloc] initWithDevID: DEMO_READER_ID
                                                          customID: DEMO_CUSTOM_ID
                                                           andType: 1];
    [reader setTrackData: [AesTrackData demoData]];
    
    return reader;
}

+ (instancetype)emptyData
{
    CardReaderData *reader = [CardReaderData new];
    [reader setPlugged: NO];
    
    return reader;
}

- (instancetype)initWithDevID:(NSString *)devID customID:(NSString *)cusID andType:(NSUInteger)type
{
    self = [super init];
    if (self) {
        self.type = type;
        self.lowBattery = NO;
        self.deviceID = devID;
        self.customID = cusID;
    }
    return self;
}

- (BOOL)isReady
{
    return (self.isPlugged && self.deviceID && self.customID)? YES : NO;
}

- (void)setupWithDeviceID:(NSString *)deviceID
{
    //TODO: check input data
    [self setDeviceID: deviceID];
}

- (void)setupWithCustomID:(NSString *)customID
{
    //TODO: check input data
    [self setCustomID: customID];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; \n plugged = %@ \n type = %lu, \n lowBattery = %i, \n deviceID = %@, \n customID = %@ \n\n", self, (self.isPlugged? @"YES" : @"NO"), (unsigned long)self.type, self.lowBattery, self.deviceID, self.customID];
}

@end
