#import "LeftCardTrackView.h"

@interface LeftCardTrackView ()

@end

@implementation LeftCardTrackView

+ (instancetype)trackView
{
    LeftCardTrackView *view = [[[UINib nibWithNibName: NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end






