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
#define lInvalidPassword        NSLocalizedStringFromTable(@"password_invalid_validation_text",  @"Authorization", @"Input View")


#import "ITPasswordTextField.h"

@implementation ITPasswordTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.keyboardType = UIKeyboardTypeDefault;
    //self.textContentType = UITextContentTypePassword;
}

#pragma mark - Accessors

- (BOOL)isValid
{
    BOOL isValid = (self.text.length >= MIN_LEN);
    self.validationWarning = (!isValid)? lValidationWarning : nil;
    
    return isValid;
}

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
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
