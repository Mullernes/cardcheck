

#import "ITTextField.h"
#import "AuthInfoView.h"

@class CardCheckedView;
@protocol AuthViewDelegate;
@interface AuthView : UIView

@property (weak, nonatomic) IBOutlet AuthInfoView *infoView;
@property (weak, nonatomic) id<AuthViewDelegate> delegate;

@property (nonatomic) BOOL correct;
@property (nonatomic) BOOL loading;

+ (instancetype)viewWithDelegate:(id<AuthViewDelegate>)delegate;

- (void)prepareUi;
- (void)resetState;
- (void)failedStateWithError:(NSError *)error;
- (void)failedStateWithText:(NSString *)text;

@end

@protocol AuthViewDelegate <NSObject>

- (id<UITextFieldDelegate>)textFieldDelegate;

@optional
- (void)authView:(AuthView *)view checkLoginDidEnter:(ITTextField *)textField;
- (void)authView:(AuthView *)view checkPasswordDidEnter:(ITTextField *)textField;
- (void)continueCardChecking:(CardCheckedView *)view;

@end
