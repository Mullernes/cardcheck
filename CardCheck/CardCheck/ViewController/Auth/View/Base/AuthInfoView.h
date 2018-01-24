//
//  SignInInfoView.h
//  SafeUMHD
//
//  Created by Ivan Tkachenko on 8/24/15.
//  Copyright (c) 2015 Ivan Tkachenko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    InfoStateLogin,
    InfoStatePhone,
    InfoStatePin,
    InfoStateSendMoney,
    InfoStateWaring
} AuthInfoState;


@interface AuthInfoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic) AuthInfoState state;

- (void)setState:(AuthInfoState)state withText:(NSString *)text animated:(BOOL)animated;

@end
