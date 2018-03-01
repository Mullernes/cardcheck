#import "RightCardTrackView.h"

@interface RightCardTrackView ()

@end

@implementation RightCardTrackView

+ (instancetype)trackView
{
    RightCardTrackView *view = [[[UINib nibWithNibName: NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end






