//
//  UIImage+Util.h
//  OkCupid
//
//  Created by Bryan Oltman on 7/23/13.
//  Copyright (c) 2013 OkCupid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util) <NSDiscardableContent>
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
- (UIImage *)imageByMaskingWithColor:(UIColor *)color;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
+ (UIImage *)imageFromColor:(UIColor *)color withSize:(CGSize)size;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxSize:(CGSize)maxSize;
- (UIImage *)crop:(CGRect)rect;
@end
