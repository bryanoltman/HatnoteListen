//
//  UIColor+Util.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/2/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)
+ (UIColor *)colorFromHex:(uint32_t)aHexValue;
+ (UIColor *)colorFromHex:(uint32_t)aHexValue alpha:(CGFloat)aAlpha;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
- (UIColor *)wayDarkerColor;
@end
