
#import <Foundation/Foundation.h>
#import "AlertViewController.h"


@protocol NotificationManagerDelegate;
@interface NotificationManager : NSObject


@property (nonatomic, getter=isEnabledAlerts) BOOL enableAlerts;
@property (nonatomic, weak) id<NotificationManagerDelegate> delegate;


+ (instancetype)sharedInstance;

#pragma mark - Alerts
- (void)showAlert:(BaseViewController *)alert;
- (void)hideAlert:(BaseViewController *)alert completion:(void (^)(void))completion;
- (void)hideLoadingAlert:(void (^)(void))completion;

#pragma mark - Status Bar
- (void)showStatusConnecting;
- (void)showStatusConnected;

@end

@protocol NotificationManagerDelegate <NSObject>

- (void)notifyManager:(NotificationManager *)manager shouldShowViewController:(BaseViewController *)controller completion:(void (^)(void))completion;

@end


/*!
 *  Used only for testing
 *
 *  TODO: remove after testing
 */

/*
    AlertViewController *controller = [AlertViewController alertControllerWithTitle:@"Test" message:@"Multi\nline\nmessage"];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    AlertViewController *controller = [AlertViewController alertControllerWithCustomView:view];
    [controller addAction:[AlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(AlertAction *action) {
        NSLog(@"CANCEL");
    }]];
    [controller addAction:[AlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(AlertAction *action) {
        NSLog(@"DELETE");
    }]];
    [controller addAction:[AlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        NSLog(@"OK");
    }]];
    UIView *actionView = [UIView new];
    actionView.backgroundColor = [UIColor blueColor];
    [controller addAction:[AlertAction actionWithCustomView:actionView handler:^(AlertAction *action) {
        NSLog(@"CUSTOM");
    }]];

    UnregisterDeviceView *view = [UnregisterDeviceView unregisterDeviceView: ];
    AlertViewController *controller = [AlertViewController alertControllerWithCustomView: view];
    [controller addAction:[AlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        NSLog(@"OK");

        UnregisterDeviceView *view = action.controller.customView;

        NSLog(@"");
    }]];

    [[NotificationManager sharedInstance] showAlert: controller];
*/
