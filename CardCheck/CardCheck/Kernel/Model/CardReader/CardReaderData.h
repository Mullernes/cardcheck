//
//  CardReader.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface CardReaderData : KLBaseModel

@property (nonatomic) NSUInteger type;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *customID;

+ (instancetype)demoData;

@end
