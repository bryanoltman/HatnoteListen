//
//  UIColor+Util.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/2/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor (Util)
+ (UIColor *)colorFromHex:(uint32_t)aHexValue
{
  return [UIColor colorFromHex:aHexValue alpha:1.0];
}

+ (UIColor *)colorFromHex:(uint32_t)aHexValue alpha:(CGFloat)aAlpha
{
  CGFloat r = 0.0f, g = 0.0f, b = 0.0f;
  CGFloat a = (aAlpha > 0.0f ? MIN(aAlpha, 1.0f) : 1.0f);

  r = ((aHexValue >> 16) & 0xFF) / 255.0f;
  g = ((aHexValue >> 8) & 0xFF) / 255.0f;
  b = (aHexValue & 0x0000FF) / 255.0f;

  return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (UIColor *)lighterColor
{
  CGFloat h, s, b, a;
  if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
  {
    return [UIColor colorWithHue:h saturation:s brightness:MIN(b * 1.3, 1.0) alpha:a];
  }

  return nil;
}

- (UIColor *)darkerColor
{
  CGFloat h, s, b, a;
  if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
  {
    return [UIColor colorWithHue:h saturation:s brightness:b * 0.75 alpha:a];
  }

  return nil;
}

- (UIColor *)wayDarkerColor
{
  CGFloat h, s, b, a;
  if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
  {
    return [UIColor colorWithHue:h saturation:s brightness:b * 0.3 alpha:1];
  }

  return nil;
}

@end
