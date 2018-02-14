//
//  ITLoadingView.m
//  LoadingAnimation
//
//  Created by Ivan Tkachenko on 2/8/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "ITLoadingView.h"

CGFloat const DURATION_A = 1.0;
CGFloat const FRAME_RATE = 1.0 / 45.0;
CGFloat const LINE_WIDTH = 2.0;

@interface ITLoadingView ()

@property (nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) UIImage *clipMask;

@end


@implementation ITLoadingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //[self startAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)startAnimating
{
    if (self.animationTimer) return;
    if (nil == self.colors) {
        self.colors = @[[UIColor whiteColor], BASE_TINT_COLOR];
    }
    
    self.alpha = 0.0;
    self.animating = YES;
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval: FRAME_RATE
                                                           target: self
                                                         selector: @selector(setNeedsDisplay)
                                                         userInfo: nil
                                                          repeats: YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)stopAnimating
{
    if (!self.animationTimer) return;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.animationTimer invalidate];
        
        self.animationTimer = nil;
        self.animating = NO;
    }];
}

#pragma mark - Accessors

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [self setupClipMask];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)setupClipMask
{
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *font = [UIFont fontWithName: @"HelveticaNeue" size: ((self.tSize)? self.tSize : 24.0)];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName : paragraphStyle};

    NSStringDrawingContext *stringContext = [NSStringDrawingContext new];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:self.title attributes:attributes];
    CGRect titleRect = [title boundingRectWithSize:rect.size options:NSStringDrawingUsesLineFragmentOrigin context:stringContext];
    
    [title drawInRect:rect];
    
    CGFloat y = rect.size.height / 2.0;
    CGFloat length = (rect.size.width - titleRect.size.width) / 2.0 - titleRect.size.height;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = LINE_WIDTH;
    
    [bezierPath moveToPoint:CGPointMake(0.0, y)];
    [bezierPath addLineToPoint:CGPointMake(length, y)];
    [bezierPath moveToPoint:CGPointMake(rect.size.width - length, y)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, y)];
    [bezierPath stroke];
    
    self.clipMask = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (void)drawRect:(CGRect)rect
{
    static CGFloat step = 0.0;
    static NSInteger index = 0;
    static NSInteger previous = -1;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.clipMask.CGImage);
    
    if (previous >= 0)
    {
        [[self.colors objectAtIndex:previous] setFill];
        CGContextFillRect(context, rect);
    }
    
    [[self.colors objectAtIndex:index] setFill];
    CGContextFillRect(context, CGRectInset(rect, (1.0 - step) * rect.size.width / 2.0, 0.0));
    CGContextRestoreGState(context);
    
    step += FRAME_RATE / DURATION_A;
    if (1.0 < step)
    {
        #if !TARGET_IPHONE_SIMULATOR
            step = 0.0;
            previous = index;
            index = (index + 1) % self.colors.count;
        #endif
    }
}

@end
