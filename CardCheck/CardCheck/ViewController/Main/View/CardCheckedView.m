#import "CardCheckedView.h"

#define lInfoText                   NSLocalizedStringFromTable(@"card_checked_info_success_text", @"Authorization", @"Info View")

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
    
    [self.infoView setState: InfoStateCard withText: lInfoText animated: NO];
}

- (void)setupWith:(CCheckResponseModel *)response
{
    [self.trackStatus setText: response.report.title];
    [self.pan setText: response.report.truncatedPan];
    [self.holder setText: response.report.holderName];
    [self.paymentSystem setText: [NSString stringWithFormat:@"%@ %@", response.report.type, response.report.issuerName]];
}

- (IBAction)next:(id)sender
{
    [self.delegate cardViewContinuePressed: self];
}
    
@end






