#import "CardCheckedView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"dev_initialize_info_default_text", @"Authorization", @"Info View")

@interface CardCheckedView ()

- (IBAction)next:(id)sender;
    
@end

@implementation CardCheckedView

#pragma mark - Accessors
- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
}

- (void)setCorrect:(BOOL)correct
{
    [super setCorrect: correct];
}

- (void)setLoading:(BOOL)loading
{
    [super setLoading: loading];
}

#pragma mark - Working

- (void)prepareUi
{
    [super prepareUi];
}

- (void)resetState
{
    [super resetState];
}

- (void)setupWith
{
    
}

- (IBAction)next:(id)sender
{
//    if ([self.retypePasswordTextField validate]) {
//        [self.retypePasswordTextField resignFirstResponder];
//        [self.delegate authView: self checkPasswordDidEnter: self.retypePasswordTextField];
//    }
//    else {
//        [self failedStateWithText: self.retypePasswordTextField.validationWarning];
//    }
}
    
@end






