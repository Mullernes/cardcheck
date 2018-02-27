

#import "SFCommentIDTextField.h"

@implementation SFCommentIDTextField

+ (NSSet *)keyPathsForValuesAffectingCorrect
{
    return [NSSet setWithObjects:@"loading", @"showsError", nil];
}

+ (NSSet *)keyPathsForValuesAffectingLoading
{
    return [NSSet setWithObjects:@"correct", @"showsError", nil];
}

+ (NSSet *)keyPathsForValuesAffectingShowsError
{
    return [NSSet setWithObjects:@"loading", @"correct", nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.tintColor = [UIColor lightGrayColor];
}

- (void)updateViews
{
    if (self.isLoading)
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
    
    self.markView.hidden = !self.showsError && !self.correct;
    self.markView.image = self.correct ? [UIImage imageNamed:@"auth_mark_valid_icon"] : [UIImage imageNamed:@"auth_mark_invalid_icon"];
}

#pragma mark - Accessors

- (void)setShowsError:(BOOL)showsError
{
    _loading = NO;
    _correct = NO;
    
    [super setShowsError:showsError];
    [self updateViews];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    _correct = NO;
    
    [super setShowsError:NO];
    [self updateViews];
}

- (void)setCorrect:(BOOL)correct
{
    _correct = correct;
    _loading = NO;
    
    [super setShowsError:!correct];
    [self updateViews];
}

@end
