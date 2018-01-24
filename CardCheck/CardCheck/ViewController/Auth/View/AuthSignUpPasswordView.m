#import "AuthSignUpPasswordView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"auth_loginID_info_signUpPassword_text", @"Authorization", @"Info View")

@interface AuthSignUpPasswordView ()

- (IBAction)signUpWithLogin:(id)sender;
    
@end

@implementation AuthSignUpPasswordView

#pragma mark - Accessors
- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
    
    id<UITextFieldDelegate> textFieldDelegate = [delegate textFieldDelegate];
    self.passwordTextField.delegate = textFieldDelegate;
    self.retypePasswordTextField.delegate = textFieldDelegate;
    
    self.retypePasswordTextField.dependencyEqual = @[self.passwordTextField];
    self.retypePasswordTextField.dependencyOrder = @[self.passwordTextField];
}

- (void)setCorrect:(BOOL)correct
{
    [super setCorrect: correct];
    
    [self.retypePasswordTextField setCorrect: correct];
}

- (void)setLoading:(BOOL)loading
{
    [super setLoading: loading];
    
    [self.retypePasswordTextField setLoading: loading];
}

#pragma mark - Working

- (void)prepareUi
{
    [super prepareUi];
    
    [self.passwordTextField setText:@""];
    [self.retypePasswordTextField setText:@""];
}

- (void)resetState
{
    [super resetState];
    
    self.passwordTextField.loading = NO;
    self.retypePasswordTextField.loading = NO;
    
    [self.infoView setState: InfoStateLogin withText: lInfoText animated: NO];
}

- (IBAction)signUpWithLogin:(id)sender
{
    if ([self.passwordTextField validate]) {
        if ([self.passwordTextField validate]) {
            if ([self.retypePasswordTextField validate]) {
                [self.retypePasswordTextField resignFirstResponder];
                [self.delegate authView: self signUpWithLoginIDDidEnter: self.retypePasswordTextField];
            }
        }
    }
}
    
@end






