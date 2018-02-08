//
//  SignInInfoView.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 8/24/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "AuthInfoView.h"

#define IMAGE_LOGIN         [UIImage imageNamed:@"auth_info_login_icon"]
#define IMAGE_CARD          [UIImage imageNamed:@"card_checking_info_icon"]
#define IMAGE_WARNING       [UIImage imageNamed:@"auth_info_warning_icon"]

#define COLOR_DEFAULT       [UIColor colorWithRed:0.55 green:0.543 blue:0.56 alpha:1.0]


@implementation AuthInfoView

- (void)setImage:(UIImage *)image warning:(BOOL)warning
{
    self.imageView.image = image;
    self.label.textColor = warning ? [UIColor blueColor] : COLOR_DEFAULT;
}

- (void)setState:(AuthInfoState)state withText:(NSString *)text animated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.25 : 0.0;
    
    [UIView transitionWithView:self duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.label.text = text;
        self.state = state;
    } completion:nil];
}

#pragma mark - Accessors

- (void)setState:(AuthInfoState)state
{
    _state = state;
    
    switch (state)
    {
        case InfoStateLogin:
            [self setImage:IMAGE_LOGIN warning:NO];
            break;
            
        case InfoStateCard:
            [self setImage:IMAGE_CARD warning:NO];
            break;
        
        case InfoStateWaring:
            [self setImage:IMAGE_WARNING warning:YES];
            break;
            
        default:
            break;
    }
}

@end
