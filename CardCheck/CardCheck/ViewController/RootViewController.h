//
//  RootViewController.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 9/18/15.
//  Copyright © 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

+ (instancetype)root;

- (void)showAuth:(id)sender;
- (void)showMain:(id)sender;

@end
