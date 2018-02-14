//
//  ITLoadingView.h
//  LoadingAnimation
//
//  Created by Ivan Tkachenko on 2/8/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ITLoadingView : UIView

@property (nonatomic) NSInteger tSize;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *colors;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
