//
//  CardImageData.m
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CardImage.h"

#import "NSData+AES.h"
#import "UIImage+Extensions.h"

#import <AssetsLibrary/AssetsLibrary.h>


extern CGFloat const ImagePhotoCompression;

@interface CardImage()

@property (nonatomic) NSUInteger length;

@end

@implementation CardImage

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = [image scaleImageToCardSize];
        self.data = [NSData dataWithData: UIImageJPEGRepresentation(self.image, ImagePhotoCompression)];
        
        self.crc32 = [self.data crc32];
        self.length = [self.data length];
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        self.name = [NSString stringWithFormat: @"name-%f", time];
    }
    return self;
}

- (NSString *)size
{
    return [NSString stringWithFormat:@"{ width = %.1f, height = %.1f }", self.image.size.width, self.image.size.height];
}

- (NSString *)ratio
{
    CGFloat value = MAX(self.image.size.width, self.image.size.height)/MIN(self.image.size.width, self.image.size.height);
    return [NSString stringWithFormat: @"{ ratio = %.1f }", value];
}

- (void)save:(void(^)(CardImage *cardImg, NSError *error))completion
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum: [self.image CGImage]
                              orientation: (ALAssetOrientation)[self.image imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              completion(self, error);
                          }];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; crc32 = %ld; length = %lu; size = %@, ratio = %@", self, self.crc32, (unsigned long)self.length, [self size], [self ratio]];
}


@end
