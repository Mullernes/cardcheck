//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "AuthRequestModel.h"

@interface AuthRequestModel()

@property (nonatomic, readwrite) NSString *login;
@property (nonatomic, readwrite) CardReaderData *reader;

@end

@implementation AuthRequestModel

+ (instancetype)requestWithLogin:(NSString *)login
                       andReader:(CardReaderData *)reader
{
    return [[AuthRequestModel alloc] initWithLogin: login andReader: reader];
}

- (instancetype)initWithLogin:(NSString *)login
                    andReader:(CardReaderData *)reader
{
    self = [super init];
    if (self) {
        self.reader = reader;
        self.login = login.copy;
        
        long long time = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        [self setupWithTime: time];
    }
    return self;
}

- (NSDictionary *)parameters
{
    return @{@"time"            :   @(self.time),
             @"cardreader_type" :   @(self.reader.type),
             @"cardreader_id"   :   self.reader.deviceID,
             @"login"           :   self.login
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
}

@end
