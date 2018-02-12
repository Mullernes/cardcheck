

#define lConnectingStatus           NSLocalizedStringFromTable(@"connecting_bar_status", @"Common", @"Animation View")


#import "NotificationManager.h"
#import "CWStatusBarNotification.h"


@interface NotificationManager()

@property (strong, nonatomic) CWStatusBarNotification *barNotification;

@property (nonatomic, strong) NSMutableArray *alerts;
@property (nonatomic, weak) BaseViewController *currentAlert;

@end

@implementation NotificationManager

+ (instancetype)sharedInstance
{
    static NotificationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NotificationManager new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.enableAlerts = YES;
        self.alerts = [NSMutableArray array];
        
        self.barNotification = [CWStatusBarNotification new];
        self.barNotification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        self.barNotification.notificationAnimationOutStyle = CWNotificationAnimationStyleBottom;
        self.barNotification.notificationAnimationType = CWNotificationAnimationTypeReplace;
        self.barNotification.notificationStyle = CWNotificationStyleStatusBarNotification;
    }
    
    return self;
}

- (void)setEnableAlerts:(BOOL)enableAlerts
{
    _enableAlerts = enableAlerts;
    if (_enableAlerts) {
        [self showNextAlert];
    }
    else
        [self hideAlert: self.currentAlert completion: nil];
}

#pragma mark - Alerts

- (void)showAlert:(BaseViewController *)alert
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    [self.alerts addObject: alert];
    
    if (nil == self.currentAlert) {
        [self showNextAlert];
    }
}

- (void)showNextAlert
{
    BaseViewController *tAlert = [self.alerts firstObject];

    if (tAlert && self.isEnabledAlerts)
    {
        self.currentAlert = tAlert;
        
        [self showViewController: self.currentAlert completion: nil];
    }
}

- (void)hideAlert:(BaseViewController *)alert completion:(void (^)(void))completion
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    if (nil == alert) return;
    
    if (alert == self.currentAlert)
    {
        [self.currentAlert.presentingViewController dismissViewControllerAnimated: YES completion: completion];
        [self.alerts removeObject: self.currentAlert];
        self.currentAlert = nil;
        
        [self showNextAlert];
    }
}

#pragma mark - Notifications

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

- (void)showViewController:(BaseViewController *)controller completion:(void (^)(void))completion
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    if ([self.delegate respondsToSelector: @selector(notifyManager:shouldShowViewController:completion:)]){
        [self.delegate notifyManager: self shouldShowViewController: controller completion: completion];
    }
}

@end
