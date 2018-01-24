#import "AuthView.h"
#import "SFPasswordTextField.h"

@interface AuthSignUpPasswordView : AuthView

@property (weak, nonatomic) IBOutlet SFPasswordTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet SFPasswordTextField *retypePasswordTextField;
    
@end

