//
//  KeyChainData.m
//  CardCheck
//
//  Created by itnesPro on 1/8/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KeyChainData.h"

static dispatch_once_t onceToken;

@interface KeyChainData()

@property (nonatomic, readwrite) NSString *commKey;

@end

@implementation KeyChainData

+ (instancetype)sharedInstance
{
    static KeyChainData *keyChain;
    
    dispatch_once(&onceToken, ^{
        keyChain = [[self alloc] init];
        
        [keyChain setCustomId: [[CardReader sharedInstance] customID]];
        [keyChain setAppDataKey: [[MandatoryData sharedInstance] appDataKey]];
        [keyChain setAppCommKey: [[MandatoryData sharedInstance] appCommKey]];
    });
    return keyChain;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        [self onSuccess: @"%@ inited with %@", CURRENT_CLASS, [self debugDescription]];
    }
    return self;
}

- (void)updateKeys
{
    [self setCustomId: [[CardReader sharedInstance] customID]];
    [self setAppDataKey: [[MandatoryData sharedInstance] appDataKey]];
    [self setAppCommKey: [[MandatoryData sharedInstance] appCommKey]];
}

- (NSString *)commKey {
    return [NSString stringWithFormat:@"%@%@", self.customId, self.appCommKey];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; \n appDataKey = %@, \n appCommKey = %@, \n commKey = %@, \n transportKey = %@, \n otp = %@, \n customID = %@ \n\n", self, self.appDataKey, self.appCommKey, self.commKey, self.transportKey, self.otp, self.customId];
}

@end
