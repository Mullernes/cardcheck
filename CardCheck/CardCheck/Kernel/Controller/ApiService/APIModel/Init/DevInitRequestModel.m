//
//  DevInitRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 1/2/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "DevInitRequestModel.h"

@interface DevInitRequestModel()

@property (nonatomic, readwrite) DevInitData *data;
@property (nonatomic, readwrite) CardReaderData *reader;

@end

@implementation DevInitRequestModel

+ (instancetype)requestWithData:(DevInitData *)data
                      andReader:(CardReaderData *)reader
{
    return [[DevInitRequestModel alloc] initWithData: data andReader: reader];
}

- (instancetype)initWithData:(DevInitData *)data
                   andReader:(CardReaderData *)reader
{
    self = [super init];
    if (self) {
        self.data = data;
        self.reader = reader;
        
        long long time = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        [self setupWithTime: time];
    }
    return self;
}

- (NSDictionary *)parameters
{
    return @{@"time"                :   @(self.time),
             @"cardreader_type"     :   @(self.reader.type),
             @"cardreader_id"       :   self.reader.deviceID,
             @"auth_req_id"         :   @(self.data.authRequestID),
             @"mobile_device_info"  :   [self.data deviceInfo],
             @"last_try_counter"    :   @(3)
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
