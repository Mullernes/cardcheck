

#import "AuthView.h"

@interface AuthView ()

@end

@implementation AuthView

+ (instancetype)viewWithDelegate:(id<AuthViewDelegate>)delegate
{
    AuthView *view = [[[UINib nibWithNibName: NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    view.delegate = delegate;
    
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareUi
{
    [self resetState];
}

- (void)resetState
{
    [self.infoView setState: InfoStateLogin withText: nil animated: NO];
}

- (void)failedStateWithError:(NSError *)error
{
    [self setCorrect: NO];
    
    [self.infoView setState: InfoStateWaring withText: [error readableDescription] animated: NO];
}

- (void)failedStateWithText:(NSString *)text
{
    [self setCorrect: NO];
    [self.infoView setState: InfoStateWaring withText: text animated: NO];
}

#pragma mark - Accessors

- (void)setDelegate:(id<AuthViewDelegate>)delegate
{
    _delegate = delegate;
}

@end
