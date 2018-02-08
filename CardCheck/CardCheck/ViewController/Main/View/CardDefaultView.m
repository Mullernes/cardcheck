#import "CardDefaultView.h"

@interface CardDefaultView ()

- (IBAction)reset:(id)sender;
- (IBAction)checkDemo:(id)sender;
    
@end

@implementation CardDefaultView

+ (instancetype)viewWithDelegate:(id<CardDefaultViewDelegate>)delegate
{
    CardDefaultView *view = [[[UINib nibWithNibName: NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    view.delegate = delegate;
    
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)reset:(id)sender
{
    [self.delegate cardViewResetPressed: self];
}

- (IBAction)checkDemo:(id)sender
{
    [self.delegate cardViewCheckDemoPressed: self];
}

@end






