#import "DeviceInitializationView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"dev_initialize_info_default_text", @"Authorization", @"Info View")

@interface DeviceInitializationView ()

- (IBAction)next:(id)sender;
    
@end

@implementation DeviceInitializationView

#pragma mark - Accessors
- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
    
    id<UITextFieldDelegate> textFieldDelegate = [delegate textFieldDelegate];
    self.passwordTextField.delegate = textFieldDelegate;
    self.retypePasswordTextField.delegate = textFieldDelegate;
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

- (void)setupWithRequestID:(long)rID
{
    [self.passwordTextField setEnabled: NO];
    [self.passwordTextField setText: [NSString stringWithFormat:@"Request ID: %li", rID]];
}

- (IBAction)next:(id)sender
{
    if ([self.retypePasswordTextField validate]) {
        [self.retypePasswordTextField resignFirstResponder];
        [self.delegate authView: self checkPasswordDidEnter: self.retypePasswordTextField];
    }
    else {
        [self failedStateWithText: self.retypePasswordTextField.validationWarning];
    }
}
    
@end






