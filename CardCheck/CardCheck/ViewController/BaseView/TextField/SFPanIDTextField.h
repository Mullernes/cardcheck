
//

#import "ITPanIDTextField.h"
#import "ActivityIndicatorColored.h"

@interface SFPanIDTextField : ITPanIDTextField

@property (weak, nonatomic) IBOutlet ActivityIndicatorColored *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *markView;

@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic) BOOL correct;

@end
