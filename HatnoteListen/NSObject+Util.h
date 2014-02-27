//
//  NSObject+Util.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/26/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Util)
- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay;
- (void)fireBlockAfterDelay:(void (^)(void))block;
@end
