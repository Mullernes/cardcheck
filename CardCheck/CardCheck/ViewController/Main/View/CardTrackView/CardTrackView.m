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

- (void)setupWith:(CCheckReportData *)report
{
    [self.trackStatus setText: report.title];
    
    [self.pan setText: report.truncatedPan];
    [self.holder setText: report.holderName];
    
    [self.paymentType setText: report.type];
    [self.paymentSystem setText: report.issuerName];
    
    [self.paymentCountry setText: report.issuerCountry];
    
    [self.blackListViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [report blackListName: idx];
        if (name) {
            UILabel *lbl = [obj viewWithTag: 99];
            [lbl setText: name];
            
             [obj setHidden: NO];
        }
        else {
            [obj setHidden: YES];
        }
    }];
}

@end






