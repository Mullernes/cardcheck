
#import "ITTextFieldValidator.h"

@implementation ITTextFieldValidator

- (instancetype)initWithValidationDelegate:(id<ITValidationDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)shouldReturn:(ITTextField *)textField
{
    [textField setShouldReturn: YES];
    [textField resignFirstResponder];
}

- (BOOL)validate:(ITTextField *)textField
{
    BOOL isValid = [(ITTextField*)textField validate];
    
    if ([self.delegate respondsToSelector:@selector(validatorDidCheckTextField:withResult:)]) {
        [self.delegate validatorDidCheckTextField: (ITTextField *)textField withResult: isValid];
    }
    else {
        NSLog(@"delegate == nil");
    }
    
    return isValid;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [(ITTextField*)textField setPhone: NO];
    
    BOOL isValid = [(ITTextField*)textField isValidInRange: range replacementString: string];
    
    if ([self.delegate respondsToSelector:@selector(validatorCheckingTextField:withResult:)]) {
        [self.delegate validatorCheckingTextField: (ITTextField*)textField withResult: isValid];
    }
    
    return YES;
    
//    if (isValid && textField.tag == 201)
//    {
//        NSString *newText = [textField.text stringByReplacingCharactersInRange: range withString: string];
//        if ([[newText XTSemanticPhone] isEqualToString: [textField.text XTSemanticPhone]] == NO) {
//            NSString *formatedPhone = [[RMPhoneFormat instance] format: newText implicitPlus: YES];
//            [textField setText: formatedPhone];
//
//            return NO;
//        }
//    }
//    else if (isValid && textField.tag == 300 && [(ITTextField*)textField isMightPhone])
//    {
//        NSString *newText = [textField.text stringByReplacingCharactersInRange: range withString: string];
//        if ([[newText XTSemanticPhone] isEqualToString: [textField.text XTSemanticPhone]] == NO)
//        {
//            [(ITTextField*)textField setPhone: YES];
//
//            NSString *formatedPhone = [[RMPhoneFormat instance] format: newText implicitPlus: YES];
//            [textField setText: formatedPhone];
//
//            return NO;
//        }
//        else if (newText.length > textField.text.length)
//        {
//            [(ITTextField*)textField setPhone: NO];
//
//            [textField setText: [newText XTSemanticLoginID]];
//
//            return NO;
//        }
//    }
    
    return isValid;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //1
    __block BOOL shouldBeginEditing = YES;
    [((ITTextField *)textField).dependencyOrder enumerateObjectsUsingBlock:^(UITextField * _Nonnull prevTextField, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isValid = [self validate: (ITTextField*)prevTextField];
        
        if (isValid == NO) {
            *stop = YES;
            shouldBeginEditing = NO;
        }
    }];
    
    //2
    if (shouldBeginEditing) {
        [(ITTextField *)textField setShowsError: NO];
        [(ITTextField *)textField setShouldReturn: NO];
    }
    
    return shouldBeginEditing;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@", CURRENT_METHOD);
    
    //0: We should check typed data only if we press "RETURN" button / Ui button "NEXT"
    if (((ITTextField *)textField).isShouldReturn == NO) return;
        
    //1: We should check if this field is equal to previous items (reEnteredPassword == enteredPassword)
    if (((ITTextField *)textField).isDependencyEqual)
    {
        __block BOOL isValid = [self validate: (ITTextField*)textField];
        if (isValid && ((ITTextField *)textField).isShouldReturn)
        {
            NSInteger tag = textField.tag;
            UIResponder *nextResponder = [textField.superview viewWithTag:tag + 1];
            
            if (nextResponder)
                [nextResponder becomeFirstResponder];
            else
                [textField resignFirstResponder];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(validatorDidCheckTextField:withResult:)])
            [self.delegate validatorDidCheckTextField: (ITTextField *)textField withResult: NO];
        else {
            NSLog(@"delegate == nil");
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [(ITTextField *)textField setShouldReturn: YES];

    [textField resignFirstResponder];
    
    return NO;
}

@end
