//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CUploadResponseModel.h"

@interface CUploadResponseModel()

@property (nonatomic, readwrite) long imgID;
@property (nonatomic, readwrite) long imgSize;
@property (nonatomic, readwrite) long imgCRC32;

@end

@implementation CUploadResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[CUploadResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super initWithRawData: data];
    if (self) {
        
        self.imgID = [[data kImageID] longValue];
        self.imgSize = [[data kImageSize] longValue];
        self.imgCRC32 = [[data kImageCRC32] longValue];
        
        if (self.code > 0) {
            [self failedInResponse: @"CUpload_Response" withCode: self.code];
        }
        else if (!self.time) {
            [self failedInMethod: CURRENT_METHOD withReason: @"Invalid response - %@", data];
        }
    }
    return self;
}

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    if (self.isCorrect) {
        return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
    }
    else if (self.failErr) {
        NSLog(@"self = %@; imgID = %li, imgSize = %li, imgCRC32 = %li", self, self.imgID, self.imgSize, self.imgCRC32);
        return self.failErr.debugDescription;
    }
    else if (self.warnErr) {
        NSLog(@"self = %@; imgID = %li, imgSize = %li, imgCRC32 = %li", self, self.imgID, self.imgSize, self.imgCRC32);
        return self.warnErr.debugDescription;
    }
    else {
        return @"undefined";
    }
}

@end

