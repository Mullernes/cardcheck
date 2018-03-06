
#import <UIKit/UIKit.h>

@interface CardTrackView : UIView

@property (weak, nonatomic) IBOutlet UILabel *trackStatus;
@property (weak, nonatomic) IBOutlet UILabel *pan;
@property (weak, nonatomic) IBOutlet UILabel *holder;

@property (weak, nonatomic) IBOutlet UILabel *paymentType;
@property (weak, nonatomic) IBOutlet UILabel *paymentSystem;
@property (weak, nonatomic) IBOutlet UILabel *paymentCountry;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *blackListViews;

+ (instancetype)trackView;

- (void)reset;
- (void)setupWith:(CCheckReportData *)report andFakeCount:(NSUInteger)fcount;

@end

