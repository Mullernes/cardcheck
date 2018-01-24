//
//  ITKeyValueObserver.h
//  Helper
//
//  Created by Ivan Tkachenko on 11/20/13.
//  Copyright (c) 2013 Youshido. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ITKVO.h"


@interface ITKeyValueObserver : NSObject

@property (nonatomic, unsafe_unretained, readonly) id object;
@property (nonatomic, copy, readonly) NSString *keyPath;
@property (nonatomic, copy) void (^block)(ITKeyValueObserver *observer, NSDictionary *change);

- (id)initWithSubject:(id)subject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(ITKeyValueObserver *observer, NSDictionary *change))block;
- (void)stopObserving;

@end
