#import "AuthView.h"

@interface CardCheckedView : AuthView

@property (weak, nonatomic) IBOutlet UILabel *trackStatus;
@property (weak, nonatomic) IBOutlet UILabel *pan;
@property (weak, nonatomic) IBOutlet UILabel *holder;
@property (weak, nonatomic) IBOutlet UILabel *paymentSystem;

- (void)setupWith:(CCheckResponseModel *)response;
    
@end

