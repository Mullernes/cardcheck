//
//  RootViewController.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/18/15.
//  Copyright © 2015 Ivan Tkachenko. All rights reserved.
//

#define lConnectingStatus           NSLocalizedStringFromTable(@"connecting_bar_status", @"Common", @"Animation View")


#import "RootViewController.h"
#import "LoadingViewController.h"
#import "CWStatusBarNotification.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) CWStatusBarNotification *barNotification;

@end

@implementation RootViewController

+ (instancetype)root
{
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    return ([controller isKindOfClass:[RootViewController class]]) ? (RootViewController *)controller : nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self baseSetup];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController *child = self.childViewControllers.lastObject;
    
    return nil != child ? [child preferredStatusBarStyle] : UIStatusBarStyleLightContent;
    
    /*
     if ([child isKindOfClass:[UINavigationController class]])
     {
     return [[(UINavigationController *)child topViewController] preferredStatusBarStyle];
     }
     
     if ([child isKindOfClass:[UITabBarController class]])
     {
     return [[[(UITabBarController *)child viewControllers] objectAtIndex:[(UITabBarController *)child selectedIndex]] preferredStatusBarStyle];
     }
     */
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([self respondsToSelector:@selector(traitCollection)])
    {
        return self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return [UIScreen mainScreen].bounds.size.width > SIZE_REGULAR ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - Ui

- (void)setupUi
{
    if (nil == self.barNotification) {
        self.barNotification = [CWStatusBarNotification new];
        self.barNotification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        self.barNotification.notificationAnimationOutStyle = CWNotificationAnimationStyleBottom;
        self.barNotification.notificationAnimationType = CWNotificationAnimationTypeReplace;
        self.barNotification.notificationStyle = CWNotificationStyleStatusBarNotification;
    }
}

- (void)showStatusConnecting
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    [self.barNotification displayNotificationWithMessage: lConnectingStatus completion: nil];
}

- (void)showStatusConnected
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    [self.barNotification dismissNotification];
}

#pragma mark - Working

- (void)baseSetup
{
    [self setupUi];
    
    [[ReaderController sharedInstance] setPluggedHandler:^(CardReader *reader)
    {
        if (reader.isPlugged)
        {
            [self setVolume: 1.0f];
            [self showStatusConnected];
        }
        else
        {
            [self setVolume: 0.5f];
            [self showStatusConnecting];
        }
        
        [self checkReaderCompatibility: reader];
    }];
}

- (void)checkReaderCompatibility:(CardReader *)reader
{
    if (reader.isReady)
    {
        [self hideInitializationIfNeeded: nil];
        
        MandatoryData *data = [MandatoryData sharedInstance];
        if (data.isExist) 
        {
            if ([data.deviceID isEqualToString: reader.deviceID]) {
                [self showMain: nil];
            }
            else {
                NSLog(@"Show recovery....");
            }
        }
        else {
            [[KeyChainData sharedInstance] updateKeys];
            [self showAuth: nil];
        }
    }
    else if (NO == reader.isPlugged)
    {
        [self showInitializationIfNeeded: nil];
    }
}

#pragma mark - ViewController

- (void)showAuth:(id)sender
{
    [self showViewController:[[UIStoryboard storyboardWithName: STORYBOARD_AUTH bundle:nil] instantiateInitialViewController] sender:sender];
}

- (void)showMain:(id)sender
{
    [self showViewController:[[UIStoryboard storyboardWithName: STORYBOARD_MAIN bundle:nil] instantiateInitialViewController] sender:sender];
}

- (void)showInitializationIfNeeded:(id)sender
{
    if ([self.presentedViewController isKindOfClass: [LoadingViewController class]] == YES) return;
    if ([[self.childViewControllers firstObject] isKindOfClass: [LoadingViewController class]] == YES) return;
    
    LoadingViewController *dvc = [LoadingViewController loadingController];
    dvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController: dvc animated: YES completion: nil];
}

- (void)hideInitializationIfNeeded:(id)sender
{
    if ([self.presentedViewController isKindOfClass: [LoadingViewController class]] == NO) return;
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)showViewController:(UIViewController *)vc sender:(id)sender
{
    UIViewController *childController = self.childViewControllers.firstObject;
    
    NSString *restorationId_1 = [vc valueForKey:@"restorationIdentifier"];
    NSString *restorationId_2 = [childController valueForKey:@"restorationIdentifier"];
    
    if ([restorationId_1 isEqualToString: restorationId_2]) {
        return;
    }
    
    vc.view.frame = self.containerView.bounds;
    vc.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    vc.view.alpha = 0.5;
    
    CGRect frame = CGRectOffset(childController.view.frame, -1.5 * childController.view.frame.size.width, 0.0);
    
    [childController willMoveToParentViewController:nil];
    [self addChildViewController:vc];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.containerView insertSubview:vc.view belowSubview:childController.view];
    
    [UIView animateWithDuration:0.4 animations:^{
        childController.view.frame = frame;
        vc.view.transform = CGAffineTransformIdentity;
        vc.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [childController.view removeFromSuperview];
        [childController removeFromParentViewController];
        [vc didMoveToParentViewController:self];
    }];
}

#pragma mark - Utils

- (BOOL)setVolume:(float)volume
{
    BOOL rez = NO;
    
    if ((volume >= 0.0f) && (volume <= 1.0f))
    {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        UISlider *volumeViewSlider = nil;
        
        for (UIView *subview in [volumeView subviews])
        {
            if ([subview isKindOfClass:[UISlider class]])
            {
                volumeViewSlider = (UISlider*)subview;
                volumeViewSlider.continuous = true;
                break;
            }
        }
        
        if (volumeViewSlider)
        {
            [volumeViewSlider setValue:volume animated:YES];
            [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            rez = YES;
        }
    }
    
    float currentVolume = [[AVAudioSession sharedInstance] outputVolume];
    NSLog(@"Plugged: output volume = %1.2f", currentVolume);
    
    return rez;
}


@end
