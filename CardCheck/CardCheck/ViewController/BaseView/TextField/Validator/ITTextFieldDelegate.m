//
//  ITTextFieldDelegate.m
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/14/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "ITTextFieldDelegate.h"
#import "ITTextField.h"

@implementation ITTextFieldDelegate

- (instancetype)initWithValidator:(id<ITValidation>)validator
{
    self = [super init];
    
    if (self)
    {
        _validator = validator;
    }
    
    return self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.validator respondsToSelector:@selector(validateTextChange:inRange:replacementString:)])
    {
        return [self.validator validateTextChange:textField inRange:range replacementString:string];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [(ITTextField *)textField setShowsError: NO];
    
    [((ITTextField *)textField).dependencyOrder enumerateObjectsUsingBlock:^(UITextField * _Nonnull tTextField, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.validator validateTextField: tTextField];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![((ITTextField *)textField) isDependencyOrder])
    {
        textField.text = @"";
        return;
    }
    
    [self.validator validateTextField: textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    UIResponder *nextResponder = [textField.superview viewWithTag:tag + 1];
    
    if (nextResponder)
    {
        [nextResponder becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}

@end
