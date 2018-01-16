//
//  AesTrackData.m
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CCheckReportData.h"

@interface CCheckReportData()

@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *holderName;
@property (nonatomic, readwrite) NSString *truncatedPan;
@property (nonatomic, readwrite) NSArray<NSString*> *blacklists;

@property (nonatomic, readwrite) NSString *issuerName;
@property (nonatomic, readwrite) NSString *issuerCountry;


@end

@implementation CCheckReportData

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super initWithRawData: data];
    if (self) {
        self.type = [data kCardType];
        self.title = [data kCardTitle];
        self.holderName = [data kHolderName];
        self.truncatedPan = [data kTruncatedPan];
        
        self.issuerName = [data kIssuerName];
        self.issuerCountry = [data kIssuerCountry];
        
        self.blacklists = [data kCardBlackLists];
    }
    return self;
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    if (self.isCorrect) {
        return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
    }
    else if (self.failErr) {
        return self.failErr.debugDescription;
    }
    else if (self.warnErr) {
        return self.warnErr.debugDescription;
    }
    else {
        return @"undefined";
    }
}

@end
