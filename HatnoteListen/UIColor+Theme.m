//
//  UIColor+Theme.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

+ (UIColor *)backgroundColor
{
    return [UIColor colorFromHex:0x0F1821];
}

+ (UIColor *)purpleDotColor
{
    return [UIColor colorFromHex:0x903DCE];
}

+ (UIColor *)greenDotColor
{
    return [UIColor colorFromHex:0x7FD491];
}

+ (UIColor *)whiteDotColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)bannerTintColor
{
    return [UIColor colorFromHex:0x0093E8 alpha:0.7];
}

@end
