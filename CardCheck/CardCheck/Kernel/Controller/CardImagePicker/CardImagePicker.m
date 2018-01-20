//
//  ImagePicker.m
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CardImagePicker.h"

@interface CardImagePicker()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *picker;

@end

@implementation CardImagePicker

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
    self.picker = [UIImagePickerController new];
    self.picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    self.picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.picker.videoMaximumDuration = 30.0;
    self.picker.delegate = self;
    
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
}

- (void)presentInView:(UIViewController *)vc
{
    [vc presentViewController: self.picker animated: YES completion: nil];
}

- (void)dismissInView:(UIViewController *)vc
{
    [vc dismissViewControllerAnimated: YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //0
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (NO == [mediaType isEqualToString: (NSString *)kUTTypeImage]) return;
    
    //1
    UIImage *originImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    CardImage *cardImage = [[CardImage alloc] initWithImage: originImg];
    
    //2
    [self.delegate cardPicker: self didPickCardImage: cardImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate cardPickerDidCancelPicking: self];
}
@end


