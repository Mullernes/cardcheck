
#import <UIKit/UIKit.h>

@protocol CardDefaultViewDelegate;
@interface CardDefaultView : UIView

@property (weak, nonatomic) id<CardDefaultViewDelegate> delegate;

+ (instancetype)viewWithDelegate:(id<CardDefaultViewDelegate>)delegate;

@end

@protocol CardDefaultViewDelegate <NSObject>

- (void)cardViewResetPressed:(CardDefaultView *)view;
- (void)cardViewCheckDemoPressed:(CardDefaultView *)view;

@end
