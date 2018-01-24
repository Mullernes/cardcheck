//
//  ITKeyboardObserver.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/1/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ITKeyboardObserver : NSObject

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) CGRect focusFrame;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
- (void)invalidate;

@end
