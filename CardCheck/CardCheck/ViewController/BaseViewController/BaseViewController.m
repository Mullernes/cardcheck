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
    
    [self setupDemoUi];
}

#pragma mark - Accessors

- (KeyChainData *)keyChain {
    if (_keyChain == nil) {
        _keyChain = [KeyChainData sharedInstance];
    }
    
    return _keyChain;
}

- (CardReader *)currentReader {
    if (_currentReader == nil) {
        _currentReader = [CardReader sharedInstance];
    }
    
    return _currentReader;
}

- (MandatoryData *)mandatoryData {
    if (_mandatoryData == nil) {
        _mandatoryData = [MandatoryData sharedInstance];
    }
    
    return _mandatoryData;
}

- (ReaderController *)readerController {
    if (_readerController == nil) {
        _readerController = [ReaderController sharedInstance];
    }
    
    return _readerController;
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

#pragma mark - Actions

- (IBAction)navBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Working

- (void)setupDemoUi
{
    //Implement in subclass
}

@end
