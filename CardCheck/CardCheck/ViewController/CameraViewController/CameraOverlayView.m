//
//  CustomOverlayView.m
//  CardCheck
//
//  Created by itnesPro on 2/26/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "CameraOverlayView.h"
#import "ActivityIndicatorColored.h"

@interface CameraOverlayView()

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;

@property (weak, nonatomic) IBOutlet UIView *takeView;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet UIView *reTakeView;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ActivityIndicatorColored *activityIndicator;


@end

@implementation CameraOverlayView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self prepareFrontSide];
}

- (void)prepareFrontSide
{
    [self.titleLbl setText: @"Лицьова сторона картки"];
    [self updateActions: NO reTake: YES send: YES];
}

- (void)prepareBackSide
{
    [self.titleLbl setText: @"Зворотня сторона картки"];
    [self updateActions: NO reTake: YES send: YES];
}

- (void)updateActions:(BOOL)take reTake:(BOOL)reTake send:(BOOL)send
{
    [self.takeView setHidden: take];
    [self.sendView setHidden: send];
    [self.reTakeView setHidden: reTake];
    
    if (take && reTake && send) {
        [self.activityView setHidden: NO];
        [self.activityIndicator startAnimating];
    }
    else {
        [self.activityView setHidden: YES];
        [self.activityIndicator stopAnimating];
    }
    
    [self.imageView setHidden: !self.takeView.isHidden];
}

- (void)updateWithImage:(UIImage *)image
{
    [self.imageView setImage: image];
    
    [self updateActions: YES reTake: NO send: NO];
}

- (IBAction)take:(id)sender
{
    NSLog(@"%@", CURRENT_METHOD);
    
    [self.delegate viewDidPressTake: self];
}

- (IBAction)reTake:(id)sender
{
    NSLog(@"%@", CURRENT_METHOD);
    
    [self updateActions: NO reTake: YES send: YES];

    [self.delegate viewDidPressReTake: self];
}

- (IBAction)send:(id)sender
{
    NSLog(@"%@", CURRENT_METHOD);
    
    [self updateActions: YES reTake: YES send: YES];
    
    [self.delegate viewDidPressSend: self];
}

@end
