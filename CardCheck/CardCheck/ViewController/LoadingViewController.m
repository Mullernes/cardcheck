//
//  LoadingViewController.m
//  SafeCall
//
//  Created by girya on 12/16/16.
//  Copyright © 2016 SafeUM. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()<ReaderControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnClean;
@property (weak, nonatomic) IBOutlet UIButton *btnDemo;

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

- (void)setupDemoUi
{
    [self.btnDemo setHidden: !DEMO_MODE];
    [self.btnClean setHidden: !DEMO_MODE];
}

- (void)baseSetup
{
    [self setupReaderController];
    [self.activityView startAnimating];
}

- (void)setupReaderController
{
    [self.readerController setDelegate: self];
}

- (void)handleReader:(CardReader *)reader
{
    NSLog(@"%@: reader => %@", CURRENT_METHOD, [reader debugDescription]);
    
    if (reader.isReady)
    {
        //1
        [self.activityView stopAnimating];
        
        //2
        if (self.mandatoryData.isExist && [self.mandatoryData.deviceID isEqualToString: reader.deviceID]) {
            [self.rootViewController showMain: nil];
        }
        else {
            [self.rootViewController showAuth: nil];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        float value = reader.isPlugged? 0.0 : 1.0;
        [self.lblDescription.layer setOpacity: value];
    }];
}

#pragma mark - Actions

- (IBAction)clean:(id)sender
{
    [[MandatoryData sharedInstance] clean];
}

- (IBAction)demo:(id)sender
{
    [self.readerController startDemoMode];
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader
{
    [self handleReader: reader];
}


@end
