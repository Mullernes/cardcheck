//
//  ITTextField.h
//  CloudKeyz
//
//  Created by Ivan Tkachenko on 6/11/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITTextField : UITextField

@property (nonatomic) UIColor *defaultColor;    // Text color
@property (nonatomic) UIColor *errorColor;      // Text color when error shown
@property (nonatomic) BOOL showsError;          // Controls textField appearance depending on showsError bool
@property (nonatomic) BOOL savesError;          // Saves showsError value when text changes, default = NO

@property (nonatomic, getter=isShouldReturn) BOOL shouldReturn;             //Indicates when we pressed the return key

@property (nonatomic, strong) NSArray *dependencyOrder;
@property (nonatomic, strong) NSArray *dependencyEqual;

@property (nonatomic, strong) NSString *validationWarning;

@property (nonatomic, getter=isPhone) BOOL phone;

- (BOOL)isMightEmail;
- (BOOL)isMightPhone;
- (BOOL)isMightLogin;

- (void)textDidChange:(id)sender;                                           // Do not call directly. Override to handle text change, need call super
- (BOOL)isValid;                                                            // Override in subclasses to check text validity
- (BOOL)validate;                                                           // Checks text validity

- (BOOL)isDependencyOrder;                                                  // Override in subclasses to check correct order in typing field (pin / confirm pin)
- (BOOL)isDependencyEqual;                                                  // Override in subclasses to check accessPin != fakePin

- (BOOL)isValidInRange:(NSRange)range replacementString:(NSString *)string;  // Override in subclasses to check text validity

@end
