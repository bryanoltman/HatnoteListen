//
//  UIImage+Util.m
//  OkCupid
//
//  Created by Bryan Oltman on 7/23/13.
//  Copyright (c) 2013 OkCupid. All rights reserved.
//

#import "UIImage+Util.h"
#import <objc/runtime.h>

@implementation UIImage (Util)

+ (void)load
{
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        method_exchangeImplementations(class_getClassMethod(self, @selector(imageNamed:)),
                                       class_getClassMethod(self, @selector(ios6ImageNamed:)));
    }
}

+ (UIImage *)ios7ImageNamed:(NSString *)imageName
{
    UIImage *ret = [UIImage ios7ImageNamed:imageName];
    if (!ret) {
//        ERROR(@"no image found for %@", imageName);
    }
    
    return ret;
}

+ (UIImage *)ios6ImageNamed:(NSString *)imageName
{
    NSString *realImageName = [NSString stringWithFormat:@"ios6_%@", imageName];
    UIImage *ret = [UIImage ios6ImageNamed:realImageName];
    if (!ret) {
//        ERROR(@"no image found for %@", realImageName);
        ret = [UIImage ios6ImageNamed:imageName];
        return ret;
    }
    
    return ret;
}

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    UIImage *img = [UIImage imageNamed:name];
    return [img imageByMaskingWithColor:color];
}

- (UIImage *)imageByMaskingWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageFromColor:(UIColor *)color withSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, (CGRect){0, 0, size.width, size.height});
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

void constrainSize(CGSize* sz, const CGSize* maxsz)
{
    if (sz->width <= maxsz->width && sz->height <= maxsz->height)
        return;
    
    CGFloat ratio = sz->width / sz->height;
    if (sz->width > maxsz->width) {
        sz->width = maxsz->width;
        sz->height = sz->width / ratio;
    }
    
    if (sz->height > maxsz->height) {
        sz->height = maxsz->height;
        sz->width = sz->height * ratio;
    }
}

void swap(CGFloat* x, CGFloat* y)
{
    CGFloat tmp = *x;
    *x = *y;
    *y = tmp;
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    return [self scaleAndRotateImage:image maxWidth:640 maxHeight:640];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    return [self scaleAndRotateImage:image maxSize:CGSizeMake(maxWidth, maxHeight)];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image maxSize:(CGSize)maxsz
{
    CGImageRef imgRef = image.CGImage;
    
    CGSize oldsz = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGSize newsz = oldsz;
    constrainSize(&newsz, &maxsz);
    bool swapped = NO;
    
    CGAffineTransform trans = CGAffineTransformIdentity;
    CGContextRef context;
    
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
            
        case UIImageOrientationUp: //orient = 0, EXIF = 1
            trans = CGAffineTransformScale(trans, 1, -1);
            trans = CGAffineTransformTranslate(trans, 0, -newsz.height);
            break;
            
        case UIImageOrientationDown: //orient = 1, EXIF = 3
            trans = CGAffineTransformScale(trans, -1, 1);
            trans = CGAffineTransformTranslate(trans, -newsz.width, 0);
            break;
            
        case UIImageOrientationLeft: //orient = 2, EXIF = 6
            swap(&newsz.height, &newsz.width);
            swapped = YES;
            trans = CGAffineTransformScale(trans, -1, 1);
            trans = CGAffineTransformTranslate(trans, -newsz.width, 0);
            trans = CGAffineTransformRotate(trans, M_PI / -2.0);
            trans = CGAffineTransformTranslate(trans, -newsz.height, 0);
            break;
            
        case UIImageOrientationRight: //orient = 3, EXIF = 8
            swap(&newsz.height, &newsz.width);
            swapped = YES;
            trans = CGAffineTransformScale(trans, -1, 1);
            trans = CGAffineTransformRotate(trans, M_PI / 2.0);
            break;
            
        case UIImageOrientationUpMirrored: //orient = 4, EXIF = 2
            trans = CGAffineTransformScale(trans, -1, -1);
            trans = CGAffineTransformTranslate(trans, -newsz.width, -newsz.height);
            break;
            
        case UIImageOrientationDownMirrored: //orient = 5, EXIF = 4
            break;
            
        case UIImageOrientationLeftMirrored: //orient = 6, EXIF = 5
            swap(&newsz.height, &newsz.width);
            swapped = YES;
            trans = CGAffineTransformRotate(trans, M_PI / 2.0);
            trans = CGAffineTransformTranslate(trans, 0, -newsz.width);
            break;
            
        case UIImageOrientationRightMirrored: //orient = 7, EXIF = 7
            swap(&newsz.height, &newsz.width);
            swapped = YES;
            trans = CGAffineTransformRotate(trans, M_PI / -2.0);
            trans = CGAffineTransformTranslate(trans, -newsz.height, 0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(newsz);
    context = UIGraphicsGetCurrentContext();
    CGRect destRect = CGRectZero;
    destRect.size = newsz;
    
    if (swapped)
        swap(&destRect.size.width, &destRect.size.height);
    
    CGContextConcatCTM(context, trans);
    CGContextDrawImage(context, destRect, imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage *)crop:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x*self.scale,
                      rect.origin.y*self.scale,
                      rect.size.width*self.scale,
                      rect.size.height*self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

#pragma mark - NSDiscardableContent
- (BOOL)beginContentAccess
{
    return YES;
}

- (void)endContentAccess
{
    // required function - do nothing
}

- (void)discardContentIfPossible
{
    // required function - do nothing    
}

- (BOOL)isContentDiscarded
{
    return NO;
}

@end
