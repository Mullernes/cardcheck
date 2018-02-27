//
//  UIImage+Extensions.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 4/3/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

- (UIImage *)scaleImageToCardSize;

- (UIImage *)imageWithSize:(CGSize)size;
- (UIImage *)imageLimitedWithSize:(CGSize)size;

- (UIImage *)imageClippedToMask:(UIImage *)mask shadowOffset:(CGSize)shadowOffset;
- (UIImage *)imageClippedToMask:(UIImage *)mask capInsets:(UIEdgeInsets)capInstes shadowOffset:(CGSize)shadowOffset;
- (UIImage *)imageClippedToPath:(UIBezierPath *)path withShadowOffset:(CGSize)shadowOffset;

@end
