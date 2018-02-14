#import "CardDefaultView.h"
#import "ITLoadingView.h"

@interface CardDefaultView ()

@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

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
//    [self.loadingView stopAnimating];
//    [self.loadingView setHidden: YES];
    
    [self.status setHidden: YES];
    
    [self.activityView stopAnimating];
    [self.activityView setHidden: YES];
}
- (void)startAnimating:(NSString *)title
{
//    if (self.loadingView.isAnimating) {
//        [self.loadingView stopAnimating];
//    };
//
//    [self.loadingView setTitle: title];
//    [self.loadingView setHidden: NO];
//    [self.loadingView startAnimating];
    
    [self.status setText: title];
    [self.status setHidden: NO];
    
    [self.activityView startAnimating];
    [self.activityView setHidden: NO];
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






