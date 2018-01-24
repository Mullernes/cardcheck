//
//  ITKeyboardObserver.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/1/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "ITKeyboardObserver.h"


@interface ITKeyboardObserver ()

@property (nonatomic, strong) id internalObserver;

@property (nonatomic) UIEdgeInsets initialInsets;
@property (nonatomic) CGPoint initialOffset;

@end


@implementation ITKeyboardObserver

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super init];
    
    if (self)
    {
        [self setScrollView:scrollView];
        [self setup];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)setup
{
    NSAssert(nil == self.internalObserver, @"Can not setup observer twice");
    
    __weak ITKeyboardObserver *weakSelf = self;
    
    self.internalObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        CGRect keyboardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        NSUInteger options = [[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        CGPoint contentOffset = weakSelf.scrollView.contentOffset;
        contentOffset.y = MAX(CGRectGetMaxY(weakSelf.focusFrame) - CGRectGetMinY(keyboardFrame), weakSelf.initialOffset.y);
        UIEdgeInsets insets = weakSelf.scrollView.contentInset;
        insets.bottom = [UIScreen mainScreen].bounds.size.height - keyboardFrame.origin.y;
        insets.bottom = MAX(weakSelf.initialInsets.bottom, insets.bottom);
        
        [UIView animateWithDuration:duration delay:0.0 options:options << 16 animations:^{
            weakSelf.scrollView.contentInset = insets;
            weakSelf.scrollView.scrollIndicatorInsets = insets;
            weakSelf.scrollView.contentOffset = contentOffset;
        } completion:nil];
    }];
}

- (void)invalidate
{
    if (!self.internalObserver) return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.internalObserver];
    
    self.internalObserver = nil;
}

#pragma mark - Accessors

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    self.initialInsets = scrollView.contentInset;
    self.initialOffset = scrollView.contentOffset;
}

@end
