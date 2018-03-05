

#define lAlertRecoveryTitle        NSLocalizedStringFromTable(@"alert_recovery_title",          @"Common", @"Alert View")
#define lAlertRecoveryMessage      NSLocalizedStringFromTable(@"alert_recovery_message",        @"Common", @"Alert View")
#define lAlertRecoveryOk           NSLocalizedStringFromTable(@"alert_recovery_button_ok",      @"Common", @"Alert View")
#define lAlertRecoveryCancel       NSLocalizedStringFromTable(@"alert_recovery_button_cancel",  @"Common", @"Alert View")


#import "RootViewController.h"

#import "LoadingViewController.h"
#import "NotificationManager.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface RootViewController ()<NotificationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) NotificationManager *notifyManager;

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

#pragma mark - Accessors

- (NotificationManager *)notifyManager {
    return [NotificationManager sharedInstance];
}

#pragma mark - Working

- (void)baseSetup
{
    [[NotificationManager sharedInstance] setDelegate: self];
    
    [[ReaderController sharedInstance] setPluggedHandler:^(CardReader *reader)
    {
        if (reader.isPlugged)
        {
            [self setVolume: 1.0f];
            [self.notifyManager showStatusConnected];
        }
        else
        {
            [self setVolume: 0.5f];
            [self.notifyManager showStatusConnecting];
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
                [self showRecovery: nil];
            }
        }
        else {
            [self showAuth: nil];
        }
    }
    else if (NO == reader.isPlugged)
    {
        [self showInitializationIfNeeded: nil];
    }
}

#pragma mark - ViewController

- (void)closeApp {
    exit(5);
}

- (void)showAuth:(id)sender
{
    [self showViewController:[[UIStoryboard storyboardWithName: STORYBOARD_AUTH bundle:nil] instantiateInitialViewController] sender:sender];
}

- (void)showMain:(id)sender
{
    [self showViewController:[[UIStoryboard storyboardWithName: STORYBOARD_MAIN bundle:nil] instantiateInitialViewController] sender:sender];
}

- (void)showRecovery:(id)sender
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: lAlertRecoveryTitle
                                                                            message: lAlertRecoveryMessage];
    [controller addAction:[AlertAction actionWithTitle: lAlertRecoveryCancel style:UIAlertActionStyleCancel handler:^(AlertAction *action) {
        [self closeApp];
    }]];
    [controller addAction:[AlertAction actionWithTitle: lAlertRecoveryOk style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [[MandatoryData sharedInstance] clean];
        [self showAuth: nil];
    }]];
    
    [self.notifyManager showAlert: controller];
}

- (void)showInitializationIfNeeded:(id)sender
{
    if ([[ReaderController sharedInstance] isReceivedData]) return;
    
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
    NSString *destinationId = [vc valueForKey:@"restorationIdentifier"];
    NSString *currentId = [[self.childViewControllers lastObject] valueForKey:@"restorationIdentifier"];
    
    if ([destinationId isEqualToString: currentId]) return;
    
    vc.view.frame = self.containerView.bounds;
    vc.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    vc.view.alpha = 0.5;
    
    UIViewController *childController = self.childViewControllers.firstObject;
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

#pragma mark - NotificationManagerDelegate

- (void)notifyManager:(NotificationManager *)manager shouldShowViewController:(BaseViewController *)controller completion:(void (^)(void))completion
{
    if ([self.presentedViewController isKindOfClass: [LoadingViewController class]])
        [self.presentedViewController presentViewController: controller animated:YES completion: completion];
    else
        [self presentViewController: controller animated:YES completion: completion];
}

@end
