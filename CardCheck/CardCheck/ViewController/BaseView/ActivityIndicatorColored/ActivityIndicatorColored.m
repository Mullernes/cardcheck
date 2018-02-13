//
//  ActivityIndicatorColored.m
//  Xomobile
//
//  Created by itnesPro on 8/12/17.
//  Copyright © 2017 SafeUM. All rights reserved.
//

#import "ActivityIndicatorColored.h"

@implementation ActivityIndicatorColored

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setColor: BASE_TINT_COLOR];
    [self setTintColor: BASE_TINT_COLOR];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
