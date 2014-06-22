//
//  HATUpdateView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATUpdateView.h"

#define kMinFontSize 10.0f

@interface HATUpdateView ()
@property (nonatomic) CGRect initialFrame;
@property (nonatomic) BOOL invert;
@end

@implementation HATUpdateView

- (instancetype)initWithFrame:(CGRect)frame andInfo:(NSDictionary *)info
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.6;
        self.backgroundColor = [UIColor clearColor];
        self.info = info;
        self.initialFrame = frame;
        self.userInteractionEnabled = NO;
        self.lastTouchDate = [NSDate distantPast];
        
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 6;
        self.layer.shadowOffset = CGSizeZero;
    }
    
    return self;
}

- (CGFloat)fontSize
{
    return MAX(kMinFontSize, self.frame.size.width / 15);
}

- (CGRect)textViewFrame
{
    return CGRectInset(self.bounds, 5, 0);
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    
    self.color = [self displayColor];
    self.invert = [info[@"change_size"] integerValue] < 0;
    
    if ([self showsText]) {
        self.textLabel = [[UILabel alloc] initWithFrame:[self textViewFrame]];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.text = [info objectForKey:@"page_title"];

        self.textLabel.font = [UIFont systemFontOfSize:[self fontSize]];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.numberOfLines = 0;
        self.textLabel.minimumScaleFactor = kMinFontSize / [self fontSize]; // scale down to the minimum font size
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:self.textLabel];
    }
}

- (void)setTextAngle:(CGFloat)textAngle
{
    _textAngle = fmodf(textAngle, 2*M_PI);
    self.textLabel.transform = CGAffineTransformMakeRotation(textAngle);
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (UIColor *)displayColor
{
    UIColor *dotColor;
    NSNumber *isAnon = self.info[@"is_anon"];
    NSNumber *isBot = self.info[@"is_bot"];
    
    // green is anon
    // purple is bot
    // white is registered
    if ([isAnon boolValue]) {
        dotColor = [UIColor greenDotColor];
    }
    else if ([isBot boolValue]) {
        dotColor = [UIColor purpleDotColor];
    }
    else {
        dotColor = [UIColor whiteDotColor];
    }
    
    return dotColor;
}

- (CGFloat)textWidthMultiple
{
    CGFloat ret;
    switch ([[HATSettings sharedSettings] textVolume]) {
        case HATTextVolumeNone:
            ret = 0.f;
            break;
        case HATTextVolumeSome:
            ret = 1.f;
            break;
        case HATTextVolumeLots:
            ret = 1.5f;
            break;
        case HATTextVolumeAll:
            ret = 1000.f;
            break;
        default:
            ret = 1.f;
            break;
    }
    
    return ret;
}

- (BOOL)showsText
{
    if (!self.info) {
        return YES;
    }
    
    NSString *text = [self.info objectForKey:@"page_title"];
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kMinFontSize]}];
    return size.width <= CGRectGetWidth([self textViewFrame]) * [self textWidthMultiple];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (![self pointInside:point withEvent:event]) {
        return nil;
    }
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    double distance = sqrt(pow((point.x - center.x), 2.0) + pow((point.y - center.y), 2.0));
    if (distance > CGRectGetHeight(self.frame) / 2) {
        return nil;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)drawRect:(CGRect)rect
{
    UIColor *highlightColor, *bgColor;
    if (self.highlighted) {
        highlightColor = self.color;
        bgColor = [self.color wayDarkerColor];
    }
    else {
        highlightColor = [self.color wayDarkerColor];
        bgColor = self.color;
    }
    
    if (self.invert) {
        UIColor *swap = bgColor;
        bgColor = highlightColor;
        highlightColor = swap;
    }
    
    self.textLabel.textColor = highlightColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [highlightColor setStroke];
    [bgColor setFill];
    CGRect bounds = CGRectInset(rect, 3, 3);
    CGContextFillEllipseInRect (context, bounds);
    CGContextFillPath(context);
}

@end
