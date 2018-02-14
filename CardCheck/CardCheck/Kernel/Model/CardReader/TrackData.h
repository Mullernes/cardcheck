//
//  AesTrackData.h
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@class ACRTrackData;
@interface TrackData : KLBaseModel

@property (nonatomic) int tr1Code;
@property (nonatomic) int tr1Length;

@property (nonatomic) int tr2Code;
@property (nonatomic) int tr2Length;

@property (nonatomic, strong) NSString *plainHexData;
@property (nonatomic, strong) NSString *cipherHexData;   //aes256

@property (nonatomic, getter=isReadable) BOOL readable;

+ (instancetype)demoTrack;
+ (instancetype)emptyTrack;

- (void)setupWithAesTrackData:(ACRTrackData *)data;

- (BOOL)isReadableTrack1;
- (BOOL)isReadableTrack2;

@end
