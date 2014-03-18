//
//  NSString+Util.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/17/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (NSRange)range
{
    return NSMakeRange(0, self.length - 1);
}

@end

@implementation NSAttributedString (Util)

- (NSRange)range
{
    return NSMakeRange(0, self.length - 1);
}

@end