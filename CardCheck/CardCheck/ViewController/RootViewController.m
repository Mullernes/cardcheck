//
//  RootViewController.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/18/15.
//  Copyright © 2015 Ivan Tkachenko. All rights reserved.
//

#define lConnectingStatus           NSLocalizedStringFromTable(@"connecting_bar_status", @"Common", @"Animation View")


#import "RootViewController.h"
#import "CWStatusBarNotification.h"


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
    
    [self setupUi];
    
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

#pragma mark - Status Bar

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

- (void)showViewController:(UIViewController *)vc sender:(id)sender
{
    UIViewController *childController = self.childViewControllers.firstObject;
    
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

- (void)showAuth:(id)sender
{
    [self showViewController:[[UIStoryboard storyboardWithName: STORYBOARD_AUTH bundle:nil] instantiateInitialViewController] sender:sender];
}

- (void)showMain:(id)sender
{
    [self showViewController:[[UIStoryboard storyboardWithName: STORYBOARD_MAIN bundle:nil] instantiateInitialViewController] sender:sender];
}

@end
