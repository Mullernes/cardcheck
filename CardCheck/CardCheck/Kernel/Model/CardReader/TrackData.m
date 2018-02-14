//
//  AesTrackData.m
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "TrackData.h"
#import "ACRAesTrackData.h"

@interface TrackData()

@end

@implementation TrackData

+ (instancetype)demoTrack
{
    TrackData *data = [TrackData new];
    [data setTr1Code: 0];
    [data setTr1Length: 69];
    
    [data setTr2Code: 0];
    [data setTr2Length: 37];
    
    [data setPlainHexData: DEMO_TRACK_DATA];
    
    return data;
}

+ (instancetype)emptyTrack {
    TrackData *data = [TrackData new];
    return data;
}

- (void)setupWithAesTrackData:(ACRTrackData *)data
{
    if ([data isKindOfClass:[ACRAesTrackData class]])
    {
        self.readable = YES;
        
        [self setTr1Code: data.track1ErrorCode];
        [self setTr2Code: data.track2ErrorCode];
        
        [self setTr1Length: data.track1Length];
        [self setTr2Length: data.track2Length];
        
        [self setPlainHexData: [HexCvtr hexFromData: ((ACRAesTrackData *)data).trackData]];
    }
    else {
        self.readable = NO;
    }
}

- (BOOL)isReadableTrack1 {
    return !self.tr1Code;
}

- (BOOL)isReadableTrack2 {
    return !self.tr2Code;
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; tr1Code = %i, tr2Code = %i, \n plainData = %@, \n cipherData = %@ \n\n", self, self.tr1Code, self.tr2Code, self.plainHexData, self.cipherHexData];
}

@end
