//
//  ImagePicker.m
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CardPickerController.h"

#import "CameraOverlayView.h"
#import "CameraViewController.h"

#import "PickerViewController.h"

@interface CardPickerController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewDelegate>

@property (nonatomic, strong) CardImage *currentCardImage;

@property (nonatomic, strong) PickerViewController *picker;

@property (nonatomic, strong) CameraOverlayView *overlayView;
@property (nonatomic, strong) CameraViewController *cameraController;

@end

@implementation CardPickerController

- (instancetype)initWithDelegate:(id<CardImagePickerDelegate>)delegate
{
    self = [super init];
    if (self) {
        [self setup];
        self.delegate = delegate;
    }
    return self;
}

- (void)setup
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        //1
        self.cameraController = [[UIStoryboard storyboardWithName: STORYBOARD_MAIN bundle:nil] instantiateViewControllerWithIdentifier: @"CameraTarget"];
        self.overlayView = (CameraViewController*)(self.cameraController.view);
        [self.overlayView setDelegate: self];
        
        //2
        self.picker = [PickerViewController new];
        self.picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        self.picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        self.picker.videoMaximumDuration = 30.0;
        self.picker.delegate = self;
        
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.showsCameraControls = NO;
    }
}

- (void)didSendImage:(BOOL)result
{
    if (result) {
        [self.overlayView prepareBackSide];
    }
    else {
        [self.overlayView prepareFrontSide];
    }
}

- (void)presentInView:(UIViewController *)vc
{
    if (nil == vc) return;
    
    __weak CardPickerController *weakSelf = self;
    [vc presentViewController: self.picker animated: YES completion:^{
        [weakSelf.overlayView prepareFrontSide];
        weakSelf.picker.cameraOverlayView = weakSelf.overlayView;
    }];
}

- (void)dismissInView:(UIViewController *)vc completion:(void(^)(void))completion
{
    if (nil == vc) return;
    
    [vc dismissViewControllerAnimated: YES completion: completion];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //0
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (NO == [mediaType isEqualToString: (NSString *)kUTTypeImage]) return;
    
    //1
    UIImage *finalImg = nil;
    UIImage *originImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *wideImg = [UIImage imageWithCGImage: originImg.CGImage scale: originImg.scale orientation: UIImageOrientationUp];
    UIImage *narrowImg = [UIImage imageWithCGImage: originImg.CGImage scale: originImg.scale orientation: UIImageOrientationRight];
    
    //2
    switch (UIApplication.sharedApplication.statusBarOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            finalImg = narrowImg;
            break;
            
        default:
            finalImg = wideImg;
            break;
    }
    
    //3
    [self.overlayView updateWithImage: finalImg];
    
    //4
    self.currentCardImage = [[CardImage alloc] initWithImage: finalImg];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate cardPickerDidCancelPicking: self];
}

#pragma mark - CameraOverlayViewDelegate

- (void)viewDidPressTake:(CameraOverlayView *)view
{
    [self.picker takePicture];
}

- (void)viewDidPressReTake:(CameraOverlayView *)view
{
    self.currentCardImage = nil;
}

- (void)viewDidPressSend:(CameraOverlayView *)view
{
    [self.delegate cardPicker: self didPickCardImage: self.currentCardImage];
}

@end


