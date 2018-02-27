//
//  ImagePicker.h
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

@protocol CardImagePickerDelegate;

@interface CardPickerController : KLBaseController

@property (nonatomic, weak) id<CardImagePickerDelegate>delegate;

- (instancetype)initWithDelegate:(id<CardImagePickerDelegate>)delegate;

- (void)didSendImage:(BOOL)result;
- (void)presentInView:(UIViewController *)vc;
- (void)dismissInView:(UIViewController *)vc completion:(void(^)(void))completion;


@end

@protocol CardImagePickerDelegate <NSObject>

- (void)cardPicker:(CardPickerController *)picker didPickCardImage:(CardImage *)image;
- (void)cardPickerDidCancelPicking:(CardPickerController *)picker;

@end
