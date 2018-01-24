

#import "ITPasswordTextField.h"
#import "ActivityIndicatorColored.h"

@interface SFPasswordTextField : ITPasswordTextField

@property (weak, nonatomic) IBOutlet ActivityIndicatorColored *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *markView;

@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic) BOOL correct;

@end
