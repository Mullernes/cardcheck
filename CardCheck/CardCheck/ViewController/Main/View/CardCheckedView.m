#import "CardCheckedView.h"
#import "LeftCardTrackView.h"
#import "RightCardTrackView.h"

#define lInfoText           NSLocalizedStringFromTable(@"card_checked_info_default_text", @"Interactive", @"Info View")
#define lFakeText           NSLocalizedStringFromTable(@"card_checked_info_fake_text", @"Interactive", @"Info View")
#define lQuestionText       NSLocalizedStringFromTable(@"card_checked_info_question_text", @"Interactive", @"Info View")


@interface CardCheckedView ()

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIStackView *stackContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContentView;

@property (weak, nonatomic) IBOutlet LeftCardTrackView *leftCardView;
@property (weak, nonatomic) IBOutlet RightCardTrackView *rightCardView;

@property (weak, nonatomic) IBOutlet UIView *extraInfo;
@property (weak, nonatomic) IBOutlet UILabel *extraInfoLbl;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (nonatomic) BOOL isFake;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraintDefault;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraintDouble;

- (IBAction)next:(id)sender;
- (IBAction)yes:(id)sender;
- (IBAction)no:(id)sender;
    
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
    
    [self.infoView setState: InfoStateCard withText: lInfoText animated: NO];
}

- (void)setupWith:(CardCheckReport *)report andStage:(BOOL)stage
{
    [self resetActionView: stage];
    [self resetWithReports: report.reports];
}

- (void)resetActionView:(BOOL)stage
{
    [self.yesButton setHidden: !stage];
    [self.noButton setHidden: !stage];
    
    [self.extraInfo setHidden: !stage];
    [self.nextButton setHidden: stage];
}

- (void)resetWithReports:(NSArray<CCheckReportData *> *)reports
{
    self.isFake = ([reports count] == 2)?YES:NO;
    
    CCheckReportData *leftReport = [reports firstObject];
    CCheckReportData *rightReport = self.isFake? [reports lastObject] : nil;
    NSUInteger fakeCount = MAX(leftReport.blacklists.count, rightReport.blacklists.count);
    
    [self.leftCardView reset];
    [self.rightCardView reset];
    
    //left
    if (leftReport) {
        [self.leftCardView setupWith: leftReport andFakeCount: fakeCount];
        [self.leftCardView setHidden: NO];
    }
    
    //right
    if (rightReport) {
        [self.rightCardView setupWith: rightReport andFakeCount: fakeCount];
        [self.rightCardView setHidden: NO];
    }
    else {
        [self.rightCardView setHidden: YES];
    }
    
    //constraints
    if (self.isFake == NO || IS_IPAD) {
        [self.contentWidthConstraintDouble setActive: NO];
        [self.contentWidthConstraintDefault setActive: YES];
        
        [self.scrollContentView setScrollEnabled: NO];
    }
    else {
        [self.contentWidthConstraintDouble setActive: YES];
        [self.contentWidthConstraintDefault setActive: NO];
        
        [self.scrollContentView setScrollEnabled: YES];
        
        UIEdgeInsets insets = self.scrollContentView.contentInset;
        [self.scrollContentView setScrollIndicatorInsets: insets];
    }
    
    //Extra info
    if (self.isFake) {
        [self.yesButton setHidden: YES];
        [self.noButton setHidden: YES];
        
        [self.extraInfo setHidden: NO];
        [self.extraInfoLbl setText: lFakeText];
        
        [self.nextButton setHidden: NO];
    }
    else {
        [self.extraInfoLbl setText: lQuestionText];
    }

    [self layoutIfNeeded];
}

- (IBAction)next:(id)sender
{
    [self.delegate cardViewContinuePressed: self isFake: self.isFake];
}

- (IBAction)yes:(id)sender
{
    [self.delegate cardViewYesPressed: self];
}

- (IBAction)no:(id)sender
{
    [self.delegate cardViewNoPressed: self];
}

@end






