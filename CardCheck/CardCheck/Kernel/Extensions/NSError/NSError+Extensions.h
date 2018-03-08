//
//  NSError+Extensions.h
//  CardCheck
//
//  Created by itnesPro on 1/2/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Extensions)

+ (NSString *)prefixWithCode:(NSInteger)code;
- (NSString *)readableDescription;

@end
