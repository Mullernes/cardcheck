//
//  CardReader.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CardReaderData.h"

@implementation CardReaderData

+ (instancetype)demoData {
    return [[CardReaderData alloc] initWithDevID: DEMO_READER_ID
                                        customID: DEMO_CUSTOM_ID
                                         andType: 1];
            
}

- (instancetype)initWithDevID:(NSString *)devID customID:(NSString *)cusID andType:(NSUInteger)type
{
    self = [super init];
    if (self) {
        self.deviceID = devID;
        self.customID = cusID;
        self.type = type;
    }
    return self;
}

@end
