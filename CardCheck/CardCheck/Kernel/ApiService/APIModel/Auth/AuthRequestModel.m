//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "AuthRequestModel.h"

@interface AuthRequestModel()

@property (nonatomic) NSUInteger time;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) CardReader *reader;


@end

@implementation AuthRequestModel

+ (instancetype)modelWithLogin:(NSString *)login andReader:(CardReader *)reader
{
    return [[AuthRequestModel alloc] initWithLogin: login andReader: reader];
}

- (instancetype)initWithLogin:(NSString *)login andReader:(CardReader *)reader
{
    self = [super init];
    if (self) {
        self.reader = reader;
        self.login = login.copy;
        self.time = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (NSDictionary *)parameters
{
    return @{@"time"            :   @(self.time),
             @"cardreader_type" :   @(self.reader.type),
             @"cardreader_id"   :   self.reader.ID,
             @"login"           :   self.login
             };
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@; json = %@", self, self.jsonString];
}

@end
