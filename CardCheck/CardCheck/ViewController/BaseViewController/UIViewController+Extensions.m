//
//  UIViewController+Extensions.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/23/15.
//  Copyright © 2015 Ivan Tkachenko. All rights reserved.
//

#import "UIViewController+Extensions.h"


@implementation UIViewController (Extensions)

- (RootViewController *)rootViewController
{
    return (RootViewController *)[self parentViewControllerOfClass:[RootViewController class]];
}

- (UIViewController *)parentViewControllerOfClass:(Class)class
{
    UIViewController *parent = [self parentViewController];
    
    while (nil != parent)
    {
        if ([parent isKindOfClass:class])
        {
            return parent;
        }
        
        parent = [parent parentViewController];
    }
    
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
