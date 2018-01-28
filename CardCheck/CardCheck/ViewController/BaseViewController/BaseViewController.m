//
//  BaseViewController.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 8/23/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([self respondsToSelector:@selector(traitCollection)])
    {
        return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return [UIScreen mainScreen].bounds.size.width > 600.0 ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

#pragma mark - Working

- (void)updatePluggedStatus:(CardReader *)reader
{
    NSLog(@"%@: reader => %@", CURRENT_METHOD, [reader debugDescription]);
    
    if (reader.isPlugged) {
        [self.rootViewController showStatusConnected];
    }
    else {
        [self.rootViewController showStatusConnecting];
    }
}

#pragma mark - Actions

- (IBAction)navBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
