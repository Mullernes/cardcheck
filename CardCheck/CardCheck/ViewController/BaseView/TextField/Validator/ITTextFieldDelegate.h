//
//  ITTextFieldDelegate.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/14/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITValidation;


@interface ITTextFieldDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) id<ITValidation> validator;

- (instancetype)initWithValidator:(id<ITValidation>)validator;

@end

@protocol ITValidation <NSObject>

- (BOOL)validateTextField:(UITextField *)textField;

@optional
- (BOOL)validateTextChange:(UITextField *)textField inRange:(NSRange)range replacementString:(NSString *)string;

@end
