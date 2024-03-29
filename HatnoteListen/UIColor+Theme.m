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
  return [UIColor colorFromHex:0x1B2024];
}

+ (UIColor *)purpleDotColor
{
  return [UIColor colorFromHex:0xCC67CB];
}

+ (UIColor *)greenDotColor
{
  return [UIColor colorFromHex:0x30DA59];
}

+ (UIColor *)whiteDotColor
{
  return [UIColor whiteColor];
}

+ (UIColor *)articleTitleViewBackgroundColor
{
  return [[UIColor blackColor] colorWithAlphaComponent:0.7];
}

+ (UIColor *)userJoinedBannerColor
{
  return [UIColor colorFromHex:0x339BE5 alpha:0.7];
}

@end
