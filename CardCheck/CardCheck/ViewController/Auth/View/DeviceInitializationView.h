#import "AuthView.h"
#import "SFPasswordTextField.h"

@interface DeviceInitializationView : AuthView

@property (nonatomic, getter=isEnabled) BOOL enable;

@property (weak, nonatomic) IBOutlet SFPasswordTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet SFPasswordTextField *retypePasswordTextField;

- (void)setupWithRequestID:(long)rID;
    
@end

