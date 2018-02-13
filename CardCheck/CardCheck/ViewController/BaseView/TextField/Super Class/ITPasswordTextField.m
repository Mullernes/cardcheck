//
//  ITEmailTextField.m
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//


#define MIN_LEN                 1

#define lValidationWarning      NSLocalizedStringFromTable(@"password_default_validation_text",  @"Authorization", @"Input View")
#define lEqualityWarning        NSLocalizedStringFromTable(@"password_equality_validation_text", @"Authorization", @"Input View")


#import "ITPasswordTextField.h"

@implementation ITPasswordTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.keyboardType = UIKeyboardTypeNumberPad;
}

#pragma mark - Accessors

- (BOOL)isValid
{
    BOOL isValid = [self isGeneralPassword: self.text];
    
    self.validationWarning = (!isValid)? lValidationWarning : nil;
    
    return DEMO_AUTH? YES : isValid;
}

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)isGeneralPassword:(NSString *)password
{
    NSString *regex = @"^([0-9]{6})$";
    NSPredicate *predTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predTest evaluateWithObject: password];
    
    return isValid;
}

- (BOOL)isDependencyEqual
{
    for (ITTextField *tTextField in self.dependencyEqual)
    {
        if (![tTextField.text isEqualToString: self.text])
        {
            if (self.text.length)
            {
                self.validationWarning = lEqualityWarning;
                tTextField.validationWarning = lEqualityWarning;
                self.showsError = YES;
            }
            else
                [self becomeFirstResponder];
            
            return NO;
        }
    }
    
    return YES;
}


@end
