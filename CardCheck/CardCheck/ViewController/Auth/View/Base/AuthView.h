

#import "ITTextField.h"
#import "AuthInfoView.h"

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
- (void)authView:(AuthView *)view sendMoneyDidEnter:(ITTextField *)textField;
- (void)authView:(AuthView *)view checkLoginIDDidEnter:(ITTextField *)textField;
- (void)authView:(AuthView *)view signInWithLoginIDDidEnter:(ITTextField *)textField;
- (void)authView:(AuthView *)view signUpWithLoginIDDidEnter:(ITTextField *)textField;
- (void)authView:(AuthView *)view checkPinDidEnter:(NSString *)pinText;
- (void)authView:(AuthView *)view changePhoneDidEnter:(id)sender;
- (void)authView:(AuthView *)view changeEmailDidEnter:(id)sender;

@end
