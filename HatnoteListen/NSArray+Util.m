//
//  NSArray+Util.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/2/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "NSArray+Util.h"

@implementation NSArray (Util)
- (id)randomObject
{
  return self[arc4random() % [self count]];
}
@end
