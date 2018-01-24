//
//  NSObject+ITKVO.m
//  Helper
//
//  Created by Ivan Tkachenko on 11/20/13.
//  Copyright (c) 2013 Youshido. All rights reserved.
//

#import "NSObject+ITKVO.h"
#import "ITKeyValueObserver.h"


@implementation NSObject (ITKVO)

- (ITKeyValueObserver *)iTObserverForKeyPath:(NSString *)keyPath withOptions:(NSKeyValueObservingOptions)options block:(void (^)(ITKeyValueObserver *observer, NSDictionary *change))block
{
    return [[ITKeyValueObserver alloc] initWithSubject:self keyPath:keyPath options:options block:block];
}

@end
