//
//  AesTrackData.m
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "AesTrackData.h"

@interface AesTrackData()

@end

@implementation AesTrackData

+ (instancetype)demoTrack {
    AesTrackData *data = [AesTrackData new];
    [data setTr1Code: 0];
    [data setTr1Length: 69];
    
    [data setTr2Code: 0];
    [data setTr2Length: 37];
    
    [data setPlainHexData: DEMO_TRACK_DATA];
    
    return data;
}

+ (instancetype)emptyTrack {
    AesTrackData *data = [AesTrackData new];
    return data;
}

- (BOOL)isExist {
    return (!self.tr1Code && !self.tr2Code && self.plainHexData)?YES:NO;
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; tr1Code = %i, tr2Code = %i, \n plainData = %@, \n cipherData = %@ \n\n", self, self.tr1Code, self.tr2Code, self.plainHexData, self.cipherHexData];
}

@end
