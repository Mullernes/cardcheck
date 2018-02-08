
#import "AuthViewController.h"

#import "AuthLoginView.h"
#import "DeviceInitializationView.h"

#import "ITKeyboardObserver.h"
#import "ITTextFieldValidator.h"


#define TAG_AUTH_LOGINID                300
#define TAG_AUTH_PASSWORD               301


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

@property (nonatomic, strong) AuthLoginView *loginIDView;
@property (nonatomic, strong) DeviceInitializationView *devInitView;

@property (nonatomic, strong) ITKeyboardObserver *keyboardObserver;
@property (nonatomic, strong) ITTextFieldValidator *textFieldValidator;

@property (nonatomic, strong) KeyChainData *keyChain;
@property (nonatomic, strong) CardReader *currentReader;
@property (nonatomic, strong) InitializationData *devInitData;


@end

@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self baseUISetup];
    [self baseDataSetup];
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

- (AuthLoginView *)loginIDView
{
    if (!_loginIDView) {
        _loginIDView = [AuthLoginView viewWithDelegate: self];
        _loginIDView.frame = self.contentView.bounds;
    }
    
    return _loginIDView;
}

- (DeviceInitializationView *)devInitView
{
    if (!_devInitView) {
        _devInitView = [DeviceInitializationView viewWithDelegate: self];
        _devInitView.frame = self.contentView.bounds;
    }
    
    return _devInitView;
}

- (InitializationData *)devInitData
{
    if (!_devInitData) {
        _devInitData = [InitializationData new];
    }
    
    return _devInitData;
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

#pragma mark - Ui

- (void)baseUISetup
{
    self.textFieldValidator = [[ITTextFieldValidator alloc] initWithValidationDelegate: self];
    
    [self.loginIDView prepareUi];
    [self showView: self.loginIDView reverse: NO];
}

- (void)showInitializationView
{
    [self.devInitView prepareUi];
    [self.devInitView setupWithRequestID: self.devInitData.authRequestID];
    
    [self showView: self.devInitView reverse: NO];
}

- (void)reverseLoginIDView
{
    [self showView: self.loginIDView reverse: YES];
}

- (void)showView:(UIView *)view reverse:(BOOL)reverse
{
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

- (void)baseDataSetup
{
    self.keyChain = [KeyChainData sharedInstance];
    self.currentReader = [CardReader sharedInstance];
}

- (void)checkLogin:(ITTextField *)loginID
{
    //1
    [self.authView setLoading: YES];
    
    //2
    NSString *login = (DEMO_AUTH && !loginID.text.length)? DEMO_LOGIN : loginID.text;
    
    //3
    AuthRequestModel *request = [AuthRequestModel requestWithLogin: login
                                                         andReader: self.currentReader];
    __weak AuthViewController *weakSelf = self;
    [[APIController sharedInstance] sendAuthRequest: request
                                     withCompletion:^(AuthResponseModel *model, NSError *error) {
                                         if (model.isCorrect)
                                         {
                                             [weakSelf.devInitData setupWithAuthResponse: model];
                                             NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                             
                                             [weakSelf.authView setCorrect: YES];
                                             [weakSelf showInitializationView];
                                         }
                                         else {
                                             NSLog(@"response = %@", model);
                                             
                                             [weakSelf.authView failedStateWithError: error];
                                         }
                                     }];
}

- (void)checkPassword:(NSString *)password
{
    //1
    long typedRequestID = self.devInitData.authRequestID;
    if (typedRequestID == self.devInitData.authRequestID)
    {
        [self calcOtp];
        
        //2 - check password
        BOOL demoAuth = (DEMO_AUTH && !self.devInitView.retypePasswordTextField.text.length)?YES:NO;
        NSString *typedOtp =  demoAuth? self.devInitData.otp : self.devInitView.retypePasswordTextField.text;
        if ([self.devInitData.otp isEqualToString: typedOtp])
        {
            [self.devInitView setLoading: YES];
            
            InitRequestModel *request = [InitRequestModel requestWithData: self.devInitData
                                                                andReader: self.currentReader];
            __weak AuthViewController *weakSelf = self;
            [[APIController sharedInstance] sendDevInitRequest: request
                                                withCompletion:^(InitResponseModel *model, NSError *error) {
                                                    if (model.isCorrect)
                                                    {
                                                        [weakSelf.devInitView setCorrect: YES];
                                                        
                                                        [weakSelf.devInitData setupWithInitResponse: model];
                                                        NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                                        
                                                        [weakSelf completeInitialization];
                                                    }
                                                    else {
                                                        NSLog(@"response = %@", model);
                                                        
                                                        [weakSelf.devInitView failedStateWithError: error];
                                                    }
                                                }];
        }
        else {
            [self.devInitView failedStateWithError: nil];
        }
    }
    else {
        [self.devInitView failedStateWithError: nil];
    }
}

#pragma mark - Kernel

- (void)calcOtp
{
    CryptoController *crp = [CryptoController sharedInstance];
    NSString *value = [crp calcOtp: self.devInitData.authResponseTime];
    [self.devInitData setupWithCalculatedOtp: value];
    
    NSLog(@"devInitData = %@", [self.devInitData debugDescription]);
}

- (void)completeInitialization
{
    CryptoController *crp = [CryptoController sharedInstance];
    
    //Otp
    [self.keyChain setOtp: self.devInitData.otp];
    
    //Transport
    NSString *hexTransportKey = [crp calcTransportKey: self.devInitData];
    [self.keyChain setTransportKey: hexTransportKey];
    
    //AppKeys
    NSData *appKeys = [crp aes128DecryptHexData: [self.devInitData cipherAppKeys]
                                     withHexKey: self.keyChain.transportKey];
    
    NSData *appDataKey = [appKeys subdataWithRange: NSMakeRange(0, 32)];
    [self.keyChain setAppDataKey: [HexCvtr hexFromData: appDataKey]];
    
    NSData *appCommKey = [appKeys subdataWithRange: NSMakeRange(32, 32)];
    [self.keyChain setAppCommKey: [HexCvtr hexFromData: appCommKey]];
    
    NSLog(@"keyChain = %@", [self.keyChain debugDescription]);
    
    //Complete
    MandatoryData *manData = [MandatoryData sharedInstance];
    [manData setAppID: self.devInitData.appID];
    [manData setDeviceID: self.currentReader.deviceID];
    
    [manData setAppDataKey: self.keyChain.appDataKey];
    [manData setAppCommKey: self.keyChain.appCommKey];
    
    [manData save];
    
    NSLog(@"MandatoryData = %@", [manData debugDescription]);
    
    [self.rootViewController showMain: nil];
}

#pragma mark - ITValidationDelegate

- (void)validatorDidCheckTextField:(ITTextField *)textField withResult:(BOOL)isValid
{
    if (isValid == NO) {
        [self.authView failedStateWithText: textField.validationWarning];
    }
    else if (textField.tag == TAG_AUTH_LOGINID) {
        [self checkLogin: textField];
    }
    else if (textField.tag == TAG_AUTH_PASSWORD) {
        [self checkPassword: textField.text];
    }
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

- (void)authView:(AuthView *)view checkLoginDidEnter:(ITTextField *)textField
{
    [self validatorDidCheckTextField: textField withResult: YES];
}

- (void)authView:(AuthView *)view checkPasswordDidEnter:(ITTextField *)textField
{
    [self validatorDidCheckTextField: textField withResult: YES];
}

@end
