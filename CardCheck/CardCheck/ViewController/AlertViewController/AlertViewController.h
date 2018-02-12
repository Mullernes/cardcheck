//
//  AlertViewController.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 6/1/16.
//  Copyright © 2016 Ivan Tkachenko. All rights reserved.
//

#import "BaseViewController.h"

@interface AlertAction : NSObject

+ (instancetype)actionWithCustomView:(UIView *)view handler:(void (^)(AlertAction *action))handler;
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(AlertAction *action))handler;

@end


@interface AlertViewController : BaseViewController

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, readonly) NSArray<AlertAction *> *actions;

+ (instancetype)alertControllerWithCustomView:(UIView *)view;
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;

- (void)addAction:(AlertAction *)action;

@end


