//
//  UIDevice+Util.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/18/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "UIDevice+Util.h"

@implementation UIDevice (Util)

- (BOOL)isPhone
{
    return [self userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

- (BOOL)isPad
{
    return [self userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

@end
