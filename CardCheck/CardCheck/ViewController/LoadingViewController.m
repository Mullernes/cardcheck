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

- (IBAction)start:(id)sender;

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
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: YES];

#if 0
    dispatch_after(0.0, dispatch_get_main_queue(), ^{
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

- (void)baseStup
{
    [self.activityView stopAnimating];
}

- (void)setupReaderController
{
    self.readerController = [ReaderController sharedInstance];
    [self.readerController setDelegate: self];
    [self.readerController start];
}

- (void)checkAndContinue:(CardReader *)reader
{
    NSLog(@"%@: reader => %@", CURRENT_METHOD, [reader debugDescription]);
    
    if (reader.isReady) {
        [self.activityView stopAnimating];
        MandatoryData *data = [MandatoryData sharedInstance];
        if (data.isExist && [data.deviceID isEqualToString: reader.deviceID]) {
            NSLog(@"showMain");
            //[self.rootViewController showMain: nil];
        }
        else {
            NSLog(@"showAuth");
            [self.rootViewController showAuth: nil];
        }
    }
}

#pragma mark - Actions

- (IBAction)start:(id)sender
{
    [self.activityView startAnimating];
    [self setupReaderController];
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)data
{
    [self checkAndContinue: data];
}


@end
