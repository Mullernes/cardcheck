//
//  CardReader.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

static dispatch_once_t onceToken;

#import "CardReader.h"

@interface CardReader()

@property (nonatomic, readwrite) NSUInteger type;
@property (nonatomic, readwrite) BOOL lowBattery;
@property (nonatomic, readwrite) NSString *deviceID;
@property (nonatomic, readwrite) NSString *customID;

@end

@implementation CardReader

+ (instancetype)demoData {
    CardReader *reader = [[CardReader alloc] initWithDevID: DEMO_READER_ID
                                                  customID: DEMO_CUSTOM_ID
                                                   andType: 1];
    [reader setTrackData: [AesTrackData demoData]];
    
    return reader;
}

+ (instancetype)sharedInstance
{
    static CardReader *reader;
    
    dispatch_once(&onceToken, ^{
        if (DEMO_MODE) {
            reader = [CardReader demoData];
        }
        else {
            reader = [[self alloc] initWithDevID: nil customID: nil andType: 1];
        }
    });
    return reader;
}

- (instancetype)initWithDevID:(NSString *)devID customID:(NSString *)cusID andType:(NSUInteger)type
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        self.type = type;
        self.lowBattery = NO;
        self.deviceID = devID;
        self.customID = cusID;
        
        [self onSuccess: @"%@ inited with %@", CURRENT_CLASS, [self debugDescription]];
    }
    return self;
}

- (void)setupDemo
{
    [self setPlugged: YES];
    [self setDeviceID: DEMO_READER_ID];
    [self setCustomID: DEMO_CUSTOM_ID];
    [self setTrackData: [AesTrackData demoData]];
}

- (BOOL)isReady
{
    return (self.isPlugged && self.deviceID && self.customID)? YES : NO;
}

- (void)setupWithDeviceID:(NSString *)deviceID
{
    //TODO: check input data
    [self setDeviceID: [deviceID lowercaseString]];
}

- (void)setupWithCustomID:(NSString *)customID
{
    //TODO: check input data
    [self setCustomID: [customID lowercaseString]];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; \n plugged = %@ \n type = %lu, \n lowBattery = %i, \n deviceID = %@, \n customID = %@ \n\n, \n trackData = %@ \n\n", self, (self.isPlugged? @"YES" : @"NO"), (unsigned long)self.type, self.lowBattery, self.deviceID, self.customID, [self.trackData debugDescription]];
}

@end
