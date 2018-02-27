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

@interface CardPickerController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayViewDelegate>

@property (nonatomic, strong) CardImage *currentCardImage;

@property (nonatomic, strong) UIImagePickerController *picker;

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
        self.picker = [UIImagePickerController new];
        self.picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        self.picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        self.picker.videoMaximumDuration = 30.0;
        self.picker.delegate = self;
        
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.showsCameraControls = NO;
        
//        float cameraAspectRatio = 5.0 / 8.0;
//        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//        float imageWidth = floorf(screenSize.width * cameraAspectRatio);
//        float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
//
//        self.picker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
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
    UIImage *originImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.currentCardImage = [[CardImage alloc] initWithImage: originImg];
    
    //2
    [self.overlayView updateWithImage: self.currentCardImage.image];
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


