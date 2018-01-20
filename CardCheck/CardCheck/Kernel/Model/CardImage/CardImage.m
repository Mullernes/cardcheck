//
//  CardImageData.m
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CardImage.h"

#define IMAGE_JPG_QUALITY        0.4f

@implementation CardImage

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.data = [NSData dataWithData: UIImageJPEGRepresentation(image, IMAGE_JPG_QUALITY)];
    }
    return self;
}

@end
