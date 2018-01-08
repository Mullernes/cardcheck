//
//  KeyChainData.m
//  CardCheck
//
//  Created by itnesPro on 1/8/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KeyChainData.h"

@interface KeyChainData()

@property (nonatomic, readwrite) NSString *commKey;

@end

@implementation KeyChainData

+ (instancetype)sharedInstance
{
    static KeyChainData *keyChain;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyChain = [[self alloc] init];
    });
    return keyChain;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInfo: @"%@ initing...", CURRENT_CLASS];
        
        [self onSuccess: @"%@ inited", CURRENT_CLASS];
    }
    return self;
}

- (NSString *)commKey {
    if (_commKey == nil) {
        _commKey = [NSString stringWithFormat:@"%@%@", self.customId, self.appCommKey];
    }
    
    return _commKey;
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; appDataKey = %@, appCommKey = %@, commKey = %@, transportKey = %@, otp = %li, customID = %@", self, self.appDataKey, self.appCommKey, self.commKey, self.transportKey, self.otp, self.customId];
}

@end
