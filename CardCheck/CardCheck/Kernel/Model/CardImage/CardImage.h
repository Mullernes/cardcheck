//
//  CardImageData.h
//  CardCheck
//
//  Created by itnesPro on 1/20/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface CardImage : KLBaseModel

@property (nonatomic) long ID;
@property (nonatomic) long crc32;
@property (nonatomic, strong) NSData *data;

- (instancetype)initWithImage:(UIImage *)image;

@end
