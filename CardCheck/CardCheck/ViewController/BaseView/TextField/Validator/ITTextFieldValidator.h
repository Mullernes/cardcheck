//
//  ITTextFieldDelegate.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/14/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import "ITTextField.h"

@protocol ITValidationDelegate;


@interface ITTextFieldValidator : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet id<ITValidationDelegate> delegate;

- (instancetype)initWithValidationDelegate:(id<ITValidationDelegate>)delegate;
- (void)shouldReturn:(ITTextField *)textField;

@end

@protocol ITValidationDelegate <NSObject>

- (void)validatorDidCheckTextField:(ITTextField *)textField withResult:(BOOL)isValid;

@optional
- (void)validatorCheckingTextField:(ITTextField *)textField withResult:(BOOL)isValid;

@end
