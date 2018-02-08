//
//  LoadingViewController.m
//  SafeCall
//
//  Created by girya on 12/16/16.
//  Copyright © 2016 SafeUM. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()<ReaderControllerDelegate>

@property (nonatomic, strong) ReaderController *readerController;

@end


@implementation LoadingViewController

+ (instancetype)loadingController
{
    LoadingViewController *controller = [[LoadingViewController alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: YES];
    
    [self baseSetup];

#if 0
    dispatch_after(3.0, dispatch_get_main_queue(), ^{
        [self.rootViewController showAuth: nil];
    });
#endif
    
#if 0
    dispatch_after(3.0, dispatch_get_main_queue(), ^{
        [self.rootViewController showMain: nil];
    });
#endif

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Working

- (void)baseSetup
{
    [self setupReaderController];
    [self.activityView startAnimating];
}

- (void)setupReaderController
{
    self.readerController = [ReaderController sharedInstance];
    [self.readerController setDelegate: self];
    [self.readerController startIfNeeded];
}

- (void)handleReader:(CardReader *)reader
{
    NSLog(@"%@: reader => %@", CURRENT_METHOD, [reader debugDescription]);
    
    if (reader.isReady)
    {
        //1
        [self.activityView stopAnimating];
        
        //2
        [[KeyChainData sharedInstance] reset];
        MandatoryData *data = [MandatoryData sharedInstance];
        
        //3
        if (data.isExist && [data.deviceID isEqualToString: reader.deviceID]) {
            [self.rootViewController showMain: nil];
        }
        else {
            [self.rootViewController showAuth: nil];
        }
    }
}

#pragma mark - Actions

- (IBAction)clean:(id)sender
{
    [[MandatoryData sharedInstance] clean];
}

- (IBAction)test:(id)sender
{
    [self.readerController demoMode];
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader
{
    [self handleReader: reader];
}


@end
