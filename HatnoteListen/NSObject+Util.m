//
//  NSObject+Util.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/26/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "NSObject+Util.h"

@implementation NSObject (Util)
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block
{
    block();
}
@end
