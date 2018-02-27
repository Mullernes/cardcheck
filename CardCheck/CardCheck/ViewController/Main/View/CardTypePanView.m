

#import "CardTypePanView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"add_pan_info_default_text", @"Interactive", @"Info View")

@interface CardTypePanView ()

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)next:(id)sender;

@end

@implementation CardTypePanView

#pragma mark - Accessors
- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
    
    id<UITextFieldDelegate> textFieldDelegate = [delegate textFieldDelegate];
    self.panIDTextField.delegate = textFieldDelegate;
}

- (void)setCorrect:(BOOL)correct
{
    [super setCorrect: correct];
    
    [self.panIDTextField setCorrect: correct];
}

- (void)setLoading:(BOOL)loading
{
    [super setLoading: loading];
    
    [self.panIDTextField setLoading: loading];
}

#pragma mark - Working

- (void)prepareUi
{
    [super prepareUi];
    
    [self.panIDTextField setText:@""];
}

- (void)resetState
{
    [super resetState];
    
    self.panIDTextField.loading = NO;
    [self.infoView setState: InfoStateLogin withText: lInfoText animated: NO];
}

#pragma mark - Actions

- (IBAction)next:(id)sender
{
    if ([self.panIDTextField isValid]) {
        [self.panIDTextField resignFirstResponder];
        [self.delegate authView: self checkCardPanDidEnter: self.panIDTextField];
    }
    else {
        [self failedStateWithText: self.panIDTextField.validationWarning];
    }
}

@end
