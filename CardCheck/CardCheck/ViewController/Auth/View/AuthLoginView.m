

#import "AuthLoginView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"auth_loginID_info_default_text", @"Authorization", @"Info View")

@interface AuthLoginView ()

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)next:(id)sender;

@end

@implementation AuthLoginView

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
    [self.infoView setState: InfoStateLogin withText: lInfoText animated: NO];
}

#pragma mark - Actions

- (IBAction)next:(id)sender
{
    if ([self.loginIDTextField isValid]) {
        [self.loginIDTextField resignFirstResponder];
        [self.delegate authView: self checkLoginDidEnter: self.loginIDTextField];
    }
    else {
        [self failedStateWithText: self.loginIDTextField.validationWarning];
    }
}

@end
