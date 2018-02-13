
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

