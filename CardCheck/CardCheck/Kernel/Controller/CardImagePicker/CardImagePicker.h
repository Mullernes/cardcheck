//
//  ImagePicker.h
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseController.h"

@protocol CardImagePickerDelegate;

@interface CardImagePicker : KLBaseController

@property (nonatomic, weak) id<CardImagePickerDelegate>delegate;

- (instancetype)initWithDelegate:(id<CardImagePickerDelegate>)delegate;

- (void)presentInView:(UIViewController *)vc;
- (void)dismissInView:(UIViewController *)vc;


@end

@protocol CardImagePickerDelegate <NSObject>

- (void)cardPicker:(CardImagePicker *)picker didPickCardImage:(CardImage *)image;
- (void)cardPickerDidCancelPicking:(CardImagePicker *)picker;

@end
