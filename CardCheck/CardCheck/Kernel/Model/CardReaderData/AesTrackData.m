//
//  AesTrackData.m
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "AesTrackData.h"

@interface AesTrackData()

//@property (nonatomic, readwrite) int tr1Code;
//@property (nonatomic, readwrite) int tr1Length;
//
//@property (nonatomic, readwrite) int tr2Code;
//@property (nonatomic, readwrite) int tr2Length;
//
//@property (nonatomic, readwrite) NSString *plainHexData;
//@property (nonatomic, readwrite) NSString *cipherHexData;   //aes256

@end

@implementation AesTrackData

+ (instancetype)demoData {
    AesTrackData *data = [AesTrackData new];
    [data setTr1Code: 0];
    //[data setTr1Length: 79];
    [data setTr1Length: 69];
    
    [data setTr2Code: 0];
    //[data setTr2Length: 40];
    [data setTr2Length: 37];
    
    [data setPlainHexData: DEMO_TRACK_DATA];
    
    return data;
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; \n plainData = %@, \n cipherData = %@ \n\n", self, self.plainHexData, self.cipherHexData];
}

@end
