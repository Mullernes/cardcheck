#import "CardDefaultView.h"


@interface CardDefaultView ()

@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *counter;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkDemoBtn;

- (IBAction)reset:(id)sender;
- (IBAction)checkDemo:(id)sender;
    
@end

@implementation CardDefaultView

#pragma mark - Accessors

- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    [super setDelegate: delegate];
}

#pragma mark - Working

- (void)prepareUi
{
    [super prepareUi];
    
    [self.resetBtn setHidden: !DEMO_MODE];
    [self.checkDemoBtn setHidden: !DEMO_MODE];
}

- (void)updateWithStatus:(NSString *)status
{
    [self.status setText: status];
    [self.status setHidden: NO];
    
    [self.counter setHidden: YES];
    
    [self.activityView startAnimating];
    [self.activityView setHidden: NO];
}

- (void)updateWithCounter:(NSUInteger)counter
{
    [self.activityView stopAnimating];
    [self.activityView setHidden: YES];
    
    [self.counter setText: [NSString stringWithFormat:@"%lu", (unsigned long)counter]];
    [self.counter setHidden: NO];
}

- (IBAction)reset:(id)sender
{
    [self.delegate cardViewResetPressed: self];
}

- (IBAction)checkDemo:(id)sender
{
    [self.delegate cardViewDemoPressed: self];
}

@end






