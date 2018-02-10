//
//  BaseViewController.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 8/23/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Extensions.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) KeyChainData *keyChain;
@property (nonatomic, strong) CardReader *currentReader;
@property (nonatomic, strong) MandatoryData *mandatoryData;
@property (nonatomic, strong) ReaderController *readerController;

- (IBAction)navBack:(id)sender;

@end
