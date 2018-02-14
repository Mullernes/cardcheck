#import "CardDefaultView.h"
#import "ITLoadingView.h"

@interface CardDefaultView ()

@property (weak, nonatomic) IBOutlet ITLoadingView *loadingView;

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

- (void)stopAnimating
{
    [self.loadingView stopAnimating];
    [self.loadingView setHidden: YES];
}
- (void)startAnimating:(NSString *)title
{
    if (self.loadingView.isAnimating) {
        [self.loadingView stopAnimating];
    };
    
    [self.loadingView setTitle: title];
    [self.loadingView setHidden: NO];
    [self.loadingView startAnimating];
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






