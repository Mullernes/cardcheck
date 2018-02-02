//
//  ITEmailTextField.m
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//


#define lValidationWarning      NSLocalizedStringFromTable(@"login_default_validation_text", @"Authorization", @"Input View")

#import "ITLoginIDTextField.h"

@implementation ITLoginIDTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.keyboardType = UIKeyboardTypeDefault;
}

#pragma mark - Accessors

- (BOOL)isValid
{
    return YES;
    
    BOOL isValid = [self isGeneralLogin: self.text];

    self.validationWarning = (!isValid)? lValidationWarning : nil;

    return isValid;
}

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)isGeneralLogin:(NSString *)login
{
    NSString *regex = @"^([a-z]{1}[a-z0-9-.]{3,31})$";
    NSPredicate *predTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predTest evaluateWithObject: [login lowercaseString]];
    
    return isValid;
}

@end
