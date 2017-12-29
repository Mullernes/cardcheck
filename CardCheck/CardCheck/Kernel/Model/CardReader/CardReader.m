//
//  CardReader.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CardReader.h"

@implementation CardReader

+ (instancetype)demoReader {
    return [[CardReader alloc] initWithID: DEMO_READER_ID andType: 1];
}

- (instancetype)initWithID:(NSString *)rID andType:(NSUInteger)type
{
    self = [super init];
    if (self) {
        self.ID = rID;
        self.type = type;
    }
    return self;
}

@end
