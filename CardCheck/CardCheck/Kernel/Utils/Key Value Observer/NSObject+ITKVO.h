//
//  NSObject+ITKVO.h
//  Helper
//
//  Created by Ivan Tkachenko on 11/20/13.
//  Copyright (c) 2013 Youshido. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITKeyValueObserver;


@interface NSObject (ITKVO)

- (ITKeyValueObserver *)iTObserverForKeyPath:(NSString *)keyPath withOptions:(NSKeyValueObservingOptions)options block:(void (^)(ITKeyValueObserver *observer, NSDictionary *change))block;

@end
