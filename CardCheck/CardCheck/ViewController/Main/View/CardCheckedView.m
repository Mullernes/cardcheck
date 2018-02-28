#import "CardCheckedView.h"
#import "LeftCardTrackView.h"
#import "RightCardTrackView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"card_checked_info_default_text", @"Interactive", @"Info View")

@interface CardCheckedView ()

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIStackView *stackContentView;

@property (weak, nonatomic) IBOutlet LeftCardTrackView *leftCardView;
@property (weak, nonatomic) IBOutlet RightCardTrackView *rightCardView;

@property (weak, nonatomic) IBOutlet UIView *extraInfo;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

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
    [self.extraInfo setHidden: !stage];
    [self.yesButton setHidden: !stage];
    [self.noButton setHidden: !stage];
    [self.nextButton setHidden: stage];
}

- (void)resetWithReports:(NSArray<CCheckReportData *> *)reports
{
    //left
    CCheckReportData *report = [reports firstObject];
    if (report) {
        [self.leftCardView setupWith: report];
        [self.leftCardView setHidden: NO];
    }
    
    //right
    BOOL isDblWidth = NO;
    if (reports.count == 2) {
        report = [reports lastObject];
        [self.rightCardView setupWith: report];
        [self.rightCardView setHidden: NO];
        
        isDblWidth = YES;
    }
    
    //constraints
    [self.contentWidthConstraintDouble setActive: isDblWidth];
    [self.contentWidthConstraintDefault setActive: !isDblWidth];

    [self layoutIfNeeded];
}

- (IBAction)next:(id)sender
{
    [self.delegate cardViewContinuePressed: self];
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






