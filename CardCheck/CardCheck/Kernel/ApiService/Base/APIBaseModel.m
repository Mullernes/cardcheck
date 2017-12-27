//
//  APIBaseModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@implementation APIBaseModel

- (id)init
{
    self = [super init];
    if (self) {
        self.signature = @"";
    }
    return self;
}

- (NSString *)jsonString {
    return [[self parameters] JSONString];
}

- (NSDictionary *)parameters {
    return @{};
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"self = %@", self];
}

@end
