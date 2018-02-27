//
//  CustomOverlayView.h
//  CardCheck
//
//  Created by itnesPro on 2/26/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraOverlayViewDelegate;
@interface CameraOverlayView : UIView

@property (nonatomic, weak) id<CameraOverlayViewDelegate> delegate;

- (void)prepareBackSide;
- (void)prepareFrontSide;
- (void)updateWithImage:(UIImage *)image;

@end

@protocol CameraOverlayViewDelegate <NSObject>

- (void)viewDidPressTake:(CameraOverlayView *)view;
- (void)viewDidPressSend:(CameraOverlayView *)view;
- (void)viewDidPressReTake:(CameraOverlayView *)view;

@end
