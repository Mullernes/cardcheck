#import "CardTrackView.h"

@interface CardTrackView ()

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

- (void)reset
{
    [self.blackListViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden: YES];
    }];
}

- (void)setupWith:(CCheckReportData *)report andFakeCount:(NSUInteger)fcount
{
    [self.trackStatus setText: report.title];
    
    [self.pan setText: report.truncatedPan];
    [self.holder setText: report.holderName];
    
    [self.paymentType setText: report.type];
    [self.paymentSystem setText: report.issuerName];
    
    [self.paymentCountry setText: report.issuerCountry];
    
    [self.blackListViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [report blackListName: idx];
        UILabel *lbl = [obj viewWithTag: 99];
        [obj setHidden: (idx>=fcount)];
        
        if (name) {
            [lbl setText: name];
            [lbl setHidden: NO];
        }
        else {
            [lbl setHidden: YES];
        }
    }];
}

@end






