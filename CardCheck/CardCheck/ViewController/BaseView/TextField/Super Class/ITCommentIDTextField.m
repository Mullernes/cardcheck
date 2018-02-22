//
//  ITEmailTextField.m
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//


#define lValidationWarning      NSLocalizedStringFromTable(@"comment_default_validation_text", @"Interactive", @"Input View")

#import "ITCommentIDTextField.h"

@implementation ITCommentIDTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.keyboardType = UIKeyboardTypeDefault;
}

#pragma mark - Accessors

- (BOOL)isValid
{
    BOOL isValid = [self isGeneralComment: self.text];

    self.validationWarning = (!isValid)? lValidationWarning : nil;

    return isValid;
}

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)isGeneralComment:(NSString *)value
{
    return value.length;
}

@end
