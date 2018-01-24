//
//  ITTextField.m
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "ITTextField.h"
#import "ITTextFieldDelegate.h"

@implementation ITTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (!self.defaultColor) self.defaultColor = self.textColor;
    [self setFont: [UIFont fontWithName:@"HelveticaNeue" size: 17.0]];
    [self addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Italic" size: 14.0];
    
    CGRect rectT = [self.placeholder boundingRectWithSize: rect.size
                                                  options: NSStringDrawingUsesLineFragmentOrigin
                                               attributes: @{NSFontAttributeName: font}
                                                  context: nil];
    
    CGRect rectNew = CGRectMake(rect.origin.x, (rect.size.height-rectT.size.height)/2, rect.size.width, rectT.size.height);
    
    NSDictionary *attrDictionary = @{NSForegroundColorAttributeName : [self.defaultColor colorWithAlphaComponent: 0.5],
                                     NSFontAttributeName : font};
    
    [[self placeholder] drawInRect: rectNew
                    withAttributes: attrDictionary];
}


- (void)textDidChange:(id)sender
{
    if (self.showsError && !self.savesError) self.showsError = NO;
}

- (BOOL)isMightEmail
{
    if (self.text.length) {
        if ([[self.text componentsSeparatedByString:@"@"] count] == 2) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isMightPhone
{
    if (self.text.length) {
        NSString *firstChar = [self.text substringToIndex: 1];
        if ([firstChar isEqualToString:@"+"] || firstChar.floatValue > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isMightLogin
{
    return (![self isMightPhone] && ![self isMightEmail]);
}

- (BOOL)isValid
{
    return self.text.length < 256? YES : NO;
}

- (BOOL)validate
{
    BOOL isValid = [self isValid];
    
    self.showsError = !isValid;
    
    return isValid;
}

- (BOOL)isDependencyOrder
{
    return ![_dependencyOrder count];
}

- (BOOL)isDependencyEqual
{
    return ![_dependencyEqual count];
}

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

#pragma mark - Accessors

- (void)setShowsError:(BOOL)showsError
{
    _showsError = showsError;
    
    UIColor *placeholderTextColor = showsError ? [self.errorColor colorWithAlphaComponent:0.75] : [self.defaultColor colorWithAlphaComponent:0.5];
    
    self.textColor = showsError ? self.errorColor : self.defaultColor;
    if (self.placeholder) self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName : placeholderTextColor}];
}

- (UIColor *)errorColor
{
    return [UIColor redColor];
}

@end
