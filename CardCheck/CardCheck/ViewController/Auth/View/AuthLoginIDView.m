

#import "AuthLoginIDView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"auth_loginID_info_default_text", @"Authorization", @"Info View")

//#define lPhoneInfoText              NSLocalizedStringFromTable(@"auth_loginID_info_phone_text", @"Authorization", @"Info View")
//#define lEmailInfoText              NSLocalizedStringFromTable(@"auth_loginID_info_email_text", @"Authorization", @"Info View")
//#define lLoginInfoText              NSLocalizedStringFromTable(@"auth_loginID_info_login_text", @"Authorization", @"Info View")

@interface AuthLoginIDView ()

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)checkLoginID:(id)sender;

@end

@implementation AuthLoginIDView

#pragma mark - Accessors
- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
    
    id<UITextFieldDelegate> textFieldDelegate = [delegate textFieldDelegate];
    self.loginIDTextField.delegate = textFieldDelegate;
}

- (void)setCorrect:(BOOL)correct
{
    [super setCorrect: correct];
    
    [self.loginIDTextField setCorrect: correct];
}

- (void)setLoading:(BOOL)loading
{
    [super setLoading: loading];
    
    [self.loginIDTextField setLoading: loading];
}

#pragma mark - Working

- (void)prepareUi
{
    [super prepareUi];
    
    [self.loginIDTextField setText:@""];
}

- (void)resetState
{
    [super resetState];
    
    self.loginIDTextField.loading = NO;
    
    NSString *info = [NSString stringWithFormat: lInfoText, [UIColor blueColor]];
    [self.infoView setState: InfoStateLogin withText: info animated: NO];
}

#pragma mark - Actions

- (IBAction)checkLoginID:(id)sender
{
    if ([self.loginIDTextField isValid]) {
        [self.loginIDTextField resignFirstResponder];
        [self.delegate authView: self checkLoginIDDidEnter: self.loginIDTextField];
    }
    else {
        [self failedStateWithText: self.loginIDTextField.validationWarning];
    }
}

@end
