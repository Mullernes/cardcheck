
#import "AuthViewController.h"

#import "AuthLoginIDView.h"
#import "AuthSignUpPasswordView.h"

#import "ITKeyboardObserver.h"
#import "ITTextFieldValidator.h"


#define TAG_AUTH_LOGINID                300
#define TAG_AUTH_PASSWORD               301

#define TAG_AUTH_PASSWORD_2             302
#define TAG_AUTH_RETYPED_PASSWORD_2     303

#define TAG_AUTH_PIN_CODE               304


#define lAlertPhoneConfirmMessage             NSLocalizedStringFromTable(@"auth_loginID_phone_alert_message_text",             @"Authorization",   @"LoginID Alerts")
#define lAlertPhoneConfirmBtnChange           NSLocalizedStringFromTable(@"auth_loginID_phone_alert_button_change_title",      @"Authorization",   @"LoginID Alerts")
#define lAlertPhoneConfirmBtnSendSMS          NSLocalizedStringFromTable(@"auth_loginID_phone_alert_button_sendsms_title",     @"Authorization",   @"LoginID Alerts")

#define lAlertEmailConfirmMessage             NSLocalizedStringFromTable(@"auth_loginID_email_alert_message_text",             @"Authorization",   @"LoginID Alerts")
#define lAlertEmailConfirmBtnChange           NSLocalizedStringFromTable(@"auth_loginID_email_alert_button_change_title",      @"Authorization",   @"LoginID Alerts")
#define lAlertEmailConfirmBtnSendCODE         NSLocalizedStringFromTable(@"auth_loginID_email_alert_button_sendsms_title",     @"Authorization",   @"LoginID Alerts")

#define lAlertSignUpLoginConfirmMessage       NSLocalizedStringFromTable(@"auth_loginID_signUpLogin_alert_message_text",         @"Authorization",   @"LoginID Alerts")
#define lAlertSignUpEmailConfirmMessage       NSLocalizedStringFromTable(@"auth_loginID_signUpEmail_alert_message_text",         @"Authorization",   @"LoginID Alerts")
#define lAlertSignUpPhoneConfirmMessage       NSLocalizedStringFromTable(@"auth_loginID_signUpPhone_alert_message_text",         @"Authorization",   @"LoginID Alerts")
#define lAlertSignUpConfirmBtnCancel          NSLocalizedStringFromTable(@"auth_loginID_signUp_alert_button_cancel_title",       @"Authorization",   @"LoginID Alerts")
#define lAlertSignUpConfirmBtnSignUp          NSLocalizedStringFromTable(@"auth_loginID_signUp_alert_button_continue_title",     @"Authorization",   @"LoginID Alerts")

@interface AuthViewController () <ITValidationDelegate, AuthViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) AuthView *authView;

@property (nonatomic, strong) AuthLoginIDView *loginIDView;
@property (nonatomic, strong) AuthSignUpPasswordView *signUpPasswordView;

@property (nonatomic, strong) ITKeyboardObserver *keyboardObserver;
@property (nonatomic, strong) ITTextFieldValidator *textFieldValidator;

@property (weak, nonatomic) IBOutlet UIButton *navBackButton;

@end

@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.textFieldValidator = [[ITTextFieldValidator alloc] initWithValidationDelegate: self];
    
    [self.loginIDView prepareUi];
    [self showView: self.loginIDView reverse: NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.keyboardObserver = [[ITKeyboardObserver alloc] initWithScrollView:self.scrollView];
    self.keyboardObserver.focusFrame = CGRectOffset(self.contentView.frame, 0.0, -self.contentView.bounds.size.height / 2.0);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.keyboardObserver invalidate];
    [self setKeyboardObserver: nil];
}

#pragma mark - Accessors

- (AuthView *)authView
{
    return [[self.contentView subviews] firstObject];
}

- (AuthLoginIDView *)loginIDView
{
    if (!_loginIDView)
    {
        _loginIDView = [AuthLoginIDView viewWithDelegate: self];
        _loginIDView.frame = self.contentView.bounds;
    }
    
    return _loginIDView;
}

- (AuthSignUpPasswordView *)signUpPasswordView
{
    if (!_signUpPasswordView)
    {
        _signUpPasswordView = [AuthSignUpPasswordView viewWithDelegate: self];
        _signUpPasswordView.frame = self.contentView.bounds;
    }
    
    return _signUpPasswordView;
}

#pragma mark - Brand

- (void)setupBrand
{
    //TODO: implement
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Actions

- (IBAction)navBack:(id)sender
{
    if ([self.authView isKindOfClass: [AuthLoginIDView class]] == NO) {
        [self reverseLoginIDView];
    }
}

#pragma mark - Ui

- (void)showSignInView
{
//    if (self.credentials.isByLogin) {
//        [self showSignInPasswordView];
//    }
//    else {
//        [self showAlertSignInConfirm];
//    }
}

- (void)showSignUpView
{
    //[self showAlertSignUpConfirm];
}

- (void)showSignUpPasswordView
{
    [self.signUpPasswordView prepareUi];
    [self showView: self.signUpPasswordView reverse: NO];
}

- (void)reverseLoginIDView
{
    [self.navBackButton setHidden: YES];
    [self showView: self.loginIDView reverse: YES];
}

- (void)showView:(UIView *)view reverse:(BOOL)reverse
{
    BOOL hidden = [view isKindOfClass:[AuthLoginIDView class]]?YES:NO;
    [self.navBackButton setHidden: hidden];
    
    CGFloat offset = reverse? -(self.view.bounds.size.width) : +(self.view.bounds.size.width);
    UIView *oldView = self.contentView.subviews.firstObject;
    
    view.frame = CGRectOffset(self.contentView.bounds, offset, 0.0);
    view.alpha = 0.0;
    
    [self.contentView addSubview: view];
    [UIView animateWithDuration:0.25 animations:^{
        oldView.frame = CGRectOffset(oldView.frame, -offset, 0.0);
        view.frame = self.contentView.bounds;
        oldView.alpha = 0.0;
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

#pragma mark - Working

- (void)checkLoginID:(ITTextField *)loginID
{
    //1
    [self.authView setLoading: YES];
    
    //2
    NSString *loginValue = loginID.text;
    
    //3
//    __weak AuthViewController *weakSelf = self;
//    [[XomTelephony sharedInstance] checkLoginID: loginValue
//                              completionHandler:^(XomAuthCredentials *credendtials, NSError *error) {
//        if (error) {
//            [weakSelf.authView failedStateWithError: error];
//        }
//        else {
//            //3.1
//            weakSelf.credentials = credendtials;
//
//            //3.2
//            if (credendtials.isExist) {
//                [weakSelf.authView setCorrect: YES];
//                [weakSelf showSignInView];
//            }
//            else if (NO == credendtials.isExist) {
//                [weakSelf.authView setLoading: NO];
//                [weakSelf showSignUpView];
//            }
//        }
//    }];
}

- (void)trySignUp:(NSString *)password
{
//    //1
//    [self.credentials setupWithPassword: password];
//
//    //2
//    __weak AuthViewController *weakSelf = self;
//    XTAuthRequestHandler handler = ^void(XTRequestState state, NSError *error) {
//        if (XTRequestStateProcessing == state) {
//            [weakSelf.authView setLoading: YES];
//        }
//        else if ((XTRequestStateCompleted == state) && (nil == error)) {
//            [weakSelf.authView setCorrect: YES];
//            [weakSelf.rootViewController showMain: nil];
//        }
//        else if ((XTRequestStateCompleted == state) && error) {
//            [weakSelf.authView failedStateWithError: error];
//        }
//        else {
//            XT_MAKE_EXEPTION;
//        }
//    };
//
//    //3
//    [[XomTelephony sharedInstance] sigUpWithLoginCredentials: self.credentials
//                                           completionHandler: handler];
}

#pragma mark - ITValidationDelegate

- (void)validatorDidCheckTextField:(ITTextField *)textField withResult:(BOOL)isValid
{
//    if (isValid == NO) {
//        [self.authView failedStateWithText: textField.validationWarning];
//    }
//    else if (textField.tag == TAG_AUTH_LOGINID) {
//        [self checkLoginID: textField];
//    }
//    else if (textField.tag == TAG_AUTH_PASSWORD) {
//        [self trySignIn: textField.text];
//    }
//    else if (textField.tag == TAG_AUTH_PASSWORD_2) {
//        [((SFPasswordTextField *)textField) setCorrect: YES];
//    }
//    else if (textField.tag == TAG_AUTH_RETYPED_PASSWORD_2) {
//        [((SFPasswordTextField *)textField) setLoading: YES];
//        [self trySignUp: textField.text];
//    }
}

- (void)validatorCheckingTextField:(ITTextField *)textField withResult:(BOOL)isValid
{
    if (!isValid) {
        [self.authView failedStateWithText: textField.validationWarning];
    }
    else {
        [self.authView resetState];
    }
}

#pragma mark - AuthViewDelegate

- (id<UITextFieldDelegate>)textFieldDelegate
{
    return self.textFieldValidator;
}

- (void)authView:(AuthView *)view checkLoginIDDidEnter:(ITTextField *)textField
{
    [self validatorDidCheckTextField: textField withResult: YES];
}

- (void)authView:(AuthView *)view signUpWithLoginIDDidEnter:(ITTextField *)textField
{
    [self validatorDidCheckTextField: textField withResult: YES];
}

@end
