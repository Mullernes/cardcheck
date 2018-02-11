//
//  LoadingViewController.h
//  SafeCall
//
//  Created by girya on 12/16/16.
//  Copyright © 2016 SafeUM. All rights reserved.
//

#import "BaseViewController.h"

@interface LoadingViewController : BaseViewController

+ (instancetype)loadingController;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end
