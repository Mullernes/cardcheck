//
//  UIImage+Extensions.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 4/3/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "UIImage+Extensions.h"

CGFloat const ImagePhotoCompression = 0.65f;

CGSize  const ImagePhotoSize1280x960 = (CGSize) { .width = 1280, .height = 960 };
CGSize  const ImagePhotoSize960x720  = (CGSize) { .width = 960,  .height = 720 };
CGSize  const ImagePhotoSize720x540  = (CGSize) { .width = 720,  .height = 540 };
CGSize  const ImagePhotoSize640x640  = (CGSize) { .width = 640,  .height = 640 };
CGSize  const ImagePhotoSize120x120  = (CGSize) { .width = 120,  .height = 120 };

CGSize  const CardImageSize8x5 = (CGSize) { .width = 1632, .height = 1020 };

@implementation UIImage (Extensions)

- (UIImage *)scaleImageToCardSize
{
    return self;
    //return [self scaleImageToSize: CardImageSize8x5];
}

- (UIImage *)scaleImageToSize:(CGSize)newSize
{
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / self.size.width;
    CGFloat aspectHeight = newSize.height / self.size.height;
    CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = self.size.width * aspectRatio;
    scaledImageRect.size.height = self.size.height * aspectRatio;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
    [self drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)imageWithSize:(CGSize)size
{
    CGSize imageSize = self.size;
    BOOL hasSameOrientation = (size.width / size.height >= 1.0) == (imageSize.width / imageSize.height >= 1.0);
    CGSize newSize = hasSameOrientation ? size : (CGSize) { .width = size.height, .height = size.width };
    
    CGFloat scaleFactor = MAX(newSize.width / imageSize.width, newSize.height / imageSize.height);
    imageSize.width *= scaleFactor;
    imageSize.height *= scaleFactor;
    
    CGPoint origin = CGPointMake((imageSize.width - newSize.width) / 2.0, (imageSize.height - newSize.height) / 2.0);
    CGRect drawRect = (CGRect) { .origin = origin, .size = newSize };
    
    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, self.scale);
    
    [self drawInRect:drawRect];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)imageLimitedWithSize:(CGSize)size
{
    CGSize imageSize = self.size;
    BOOL hasSameOrientation = (size.width / size.height >= 1.0) == (imageSize.width / imageSize.height >= 1.0);
    CGSize newSize = hasSameOrientation ? size : (CGSize) { .width = size.height, .height = size.width };
    
    CGFloat scaleFactor = MIN(newSize.width / imageSize.width, newSize.height / imageSize.height);
    imageSize.width *= scaleFactor;
    imageSize.height *= scaleFactor;
    
    CGRect drawRect = (CGRect) { .origin = CGPointZero, .size = imageSize };
    
    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, self.scale);
    
    [self drawInRect:drawRect];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)imageClippedToMask:(UIImage *)mask shadowOffset:(CGSize)shadowOffset
{
    CGRect drawRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    CGSize size = CGSizeMake(self.size.width + 2 * shadowOffset.width, self.size.height + 2 * shadowOffset.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, drawRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSaveGState(context);
    CGContextSetShadow(context, shadowOffset, shadowOffset.width);
    CGContextDrawImage(context, drawRect, mask.CGImage);
    CGContextRestoreGState(context);
    
    CGContextClipToMask(context, drawRect, mask.CGImage);
    CGContextDrawImage(context, drawRect, self.CGImage);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)imageClippedToMask:(UIImage *)mask capInsets:(UIEdgeInsets)capInstes shadowOffset:(CGSize)shadowOffset
{
    CGRect drawRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    CGSize size = CGSizeMake(self.size.width + shadowOffset.width, self.size.height + shadowOffset.height);
    UIImage *resizableMask = [mask resizableImageWithCapInsets:capInstes resizingMode:UIImageResizingModeStretch];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [resizableMask drawInRect:drawRect];
    resizableMask = UIGraphicsGetImageFromCurrentImageContext();
    CGContextClearRect(context, drawRect);
    CGContextTranslateCTM(context, 0.0, drawRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSaveGState(context);
    CGContextSetShadow(context, shadowOffset, shadowOffset.width);
    CGContextDrawImage(context, drawRect, resizableMask.CGImage);
    CGContextRestoreGState(context);
    
    CGContextClipToMask(context, drawRect, resizableMask.CGImage);
    CGContextDrawImage(context, drawRect, self.CGImage);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)imageClippedToPath:(UIBezierPath *)path withShadowOffset:(CGSize)shadowOffset
{
    CGRect drawRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    CGSize size = CGSizeMake(self.size.width + shadowOffset.width, self.size.height + shadowOffset.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, drawRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    CGContextDrawImage(context, drawRect, self.CGImage);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    
    CGContextClearRect(context, drawRect);
    CGContextSetShadow(context, shadowOffset, shadowOffset.width);
    CGContextDrawImage(context, drawRect, result.CGImage);
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
