//
//  ITEmailTextField.m
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//


#define MIN_LEN                 1

#define lValidationWarning      NSLocalizedStringFromTable(@"password_default_validation_text",  @"Interactive", @"Input View")


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
    NSString *newText = [self.text stringByReplacingCharactersInRange: range withString: string];
    BOOL isValid = (newText.length <= 6);
    
    self.validationWarning = (!isValid)? lValidationWarning : nil;
    
    return isValid;
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
    return YES;
}


@end
