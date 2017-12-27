//
//  APIBaseModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface APIBaseModel : KLBaseModel

@property (nonatomic, strong) NSString *signature;

- (NSString *)jsonString;
- (NSDictionary *)parameters;
- (NSString *)debugDescription;

@end
