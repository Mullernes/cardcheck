//
//  ITEmailTextField.m
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//


#define lValidationWarning      NSLocalizedStringFromTable(@"pan_default_validation_text", @"Interactive", @"Input View")

#import "ITPanIDTextField.h"

@implementation ITPanIDTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.keyboardType = UIKeyboardTypeNumberPad;
}

#pragma mark - Accessors

- (BOOL)isValid
{
    BOOL isValid = [self isGeneralPan: self.text];

    self.validationWarning = (!isValid)? lValidationWarning : nil;

    return isValid;
}

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)isGeneralPan:(NSString *)value
{
    if (self.text.length == 0) return YES;
    
    NSString *regex = @"^([0-9]{13,19})$";
    NSPredicate *predTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predTest evaluateWithObject: [value lowercaseString]];
    
    return isValid;
}

@end
