#import "CardTrackView.h"

@interface CardTrackView ()

@property (weak, nonatomic) IBOutlet UILabel *pan;
@property (weak, nonatomic) IBOutlet UILabel *holder;
@property (weak, nonatomic) IBOutlet UILabel *trackStatus;
@property (weak, nonatomic) IBOutlet UILabel *paymentSystem;

@end

@implementation CardTrackView

+ (instancetype)trackView
{
    CardTrackView *view = [[[UINib nibWithNibName: NSStringFromClass([self class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setupWith:(CCheckReportData *)report
{
    [self.trackStatus setText: report.title];
    [self.pan setText: report.truncatedPan];
    [self.holder setText: report.holderName];
    [self.paymentSystem setText: [NSString stringWithFormat:@"%@ %@", report.type, report.issuerName]];
}

@end






