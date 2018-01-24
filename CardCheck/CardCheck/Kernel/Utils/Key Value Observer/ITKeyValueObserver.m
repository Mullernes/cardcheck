//
//  ITKeyValueObserver.m
//  Helper
//
//  Created by Ivan Tkachenko on 11/20/13.
//  Copyright (c) 2013 Youshido. All rights reserved.
//

#import "ITKeyValueObserver.h"

static void *ITKeyValueObserverContext = &ITKeyValueObserverContext;

@interface ITKeyValueObserver ()

@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic) NSKeyValueObservingOptions options;

@end


@implementation ITKeyValueObserver

- (id)initWithSubject:(id)subject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(ITKeyValueObserver *, NSDictionary *))block
{
    self = [super init];
    
    if (self)
    {
        self.object = subject;
        self.keyPath = keyPath;
        self.options = options;
        self.block = block;
        
        [subject addObserver:self forKeyPath:keyPath options:options context:ITKeyValueObserverContext];
    }
    
    return self;
}

- (void)dealloc
{
    [self stopObserving];
}

- (void)stopObserving
{
    [self.object removeObserver:self forKeyPath:self.keyPath context:ITKeyValueObserverContext];
    
    self.object = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == ITKeyValueObserverContext)
    {
        if (self.block)
        {
            self.block(self, change);
        }
    }
}

@end
