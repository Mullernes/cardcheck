#import "CardCheckedView.h"
#import "CardTrackView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"card_checked_info_default_text", @"Authorization", @"Info View")

@interface CardCheckedView ()

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIStackView *stackContentView;

@property (weak, nonatomic) IBOutlet UIView *extraInfo;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraintDefault;

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
    __block NSArray<CardTrackView *> *views = @[];
    [report.reports enumerateObjectsUsingBlock:^(CCheckReportData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CardTrackView *trackView = [CardTrackView trackView];
        [trackView setupWith: obj];
        views = [views arrayByAddingObject: trackView];
    }];
    
    [self resetActionView: stage];
    [self resetWithTrackViews: views];
}

- (void)resetActionView:(BOOL)stage
{
    [self.extraInfo setHidden: !stage];
    [self.yesButton setHidden: !stage];
    [self.noButton setHidden: !stage];
    [self.nextButton setHidden: stage];
}

- (void)resetWithTrackViews:(NSArray<CardTrackView *> *)views
{
    //Clean old views
    for (UIView *view in self.stackContentView.subviews) {
        [view removeFromSuperview];
    }
    [self.stackContentView removeConstraints: self.stackContentView.constraints.copy];
    
    //Add new
    UIView *prevView = nil;
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (CardTrackView *trackView in views)
    {
        [trackView setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem: trackView
                                                             attribute: NSLayoutAttributeTop
                                                             relatedBy: NSLayoutRelationEqual
                                                                toItem: self.stackContentView
                                                             attribute: NSLayoutAttributeTop
                                                            multiplier: 1.0
                                                              constant: 0.0]];
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem: trackView
                                                             attribute: NSLayoutAttributeBottom
                                                             relatedBy: NSLayoutRelationEqual
                                                                toItem: self.stackContentView
                                                             attribute: NSLayoutAttributeBottom
                                                            multiplier: 1.0
                                                              constant: 0.0]];
        
        if (prevView) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem: trackView
                                                                 attribute: NSLayoutAttributeLeading
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: prevView
                                                                 attribute: NSLayoutAttributeTrailing
                                                                multiplier: 1.0
                                                                  constant: 1.0]];
            
            [constraints addObject: [NSLayoutConstraint constraintWithItem: trackView
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: prevView
                                                                 attribute: NSLayoutAttributeWidth
                                                                multiplier: 1.0
                                                                  constant: 0.0]];
        }
        else {
            [constraints addObject: [NSLayoutConstraint constraintWithItem: trackView
                                                                 attribute: NSLayoutAttributeLeading
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.stackContentView
                                                                 attribute: NSLayoutAttributeLeading
                                                                multiplier: 1.0
                                                                  constant: 0.0]];
        }
        
        [trackView addConstraint:[NSLayoutConstraint constraintWithItem: trackView
                                                               attribute: NSLayoutAttributeWidth
                                                               relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                                  toItem: nil
                                                               attribute: NSLayoutAttributeNotAnAttribute
                                                              multiplier: 1.0
                                                                constant: 0.0]];
        [self.stackContentView addSubview: trackView];
        prevView = trackView;
    }
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem: prevView
                                                         attribute: NSLayoutAttributeTrailing
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: self.stackContentView
                                                         attribute: NSLayoutAttributeTrailing
                                                        multiplier: 1.0
                                                          constant: 0.0]];
    
    [self.stackContentView addConstraints: constraints];
    
//    BOOL doubleWidth = ([views count] == 2)? YES : NO;
//    [self.contentView layoutIfNeeded];
//    [self.stackContentView layoutIfNeeded];
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






