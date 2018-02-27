

#import "CardTypeCommentView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"add_comment_info_default_text", @"Interactive", @"Info View")

@interface CardTypeCommentView ()

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)next:(id)sender;

@end

@implementation CardTypeCommentView

#pragma mark - Accessors
- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
    
    id<UITextFieldDelegate> textFieldDelegate = [delegate textFieldDelegate];
    self.commentIDTextField.delegate = textFieldDelegate;
}

- (void)setCorrect:(BOOL)correct
{
    [super setCorrect: correct];
    
    [self.commentIDTextField setCorrect: correct];
}

- (void)setLoading:(BOOL)loading
{
    [super setLoading: loading];
    
    [self.commentIDTextField setLoading: loading];
}

#pragma mark - Working

- (void)prepareUi
{
    [super prepareUi];
    
    [self.commentIDTextField setText:@""];
}

- (void)resetState
{
    [super resetState];
    
    self.commentIDTextField.loading = NO;
    [self.infoView setState: InfoStateLogin withText: lInfoText animated: NO];
}

#pragma mark - Actions

- (IBAction)next:(id)sender
{
    if ([self.commentIDTextField isValid]) {
        [self.commentIDTextField resignFirstResponder];
        [self.delegate authView: self checkCardCommentDidEnter: self.commentIDTextField];
    }
    else {
        [self failedStateWithText: self.commentIDTextField.validationWarning];
    }
}

@end
