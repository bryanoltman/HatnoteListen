//
//  HATUpdateView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATUpdateView.h"

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
    }
    
    return self;
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    
    self.color = [self displayColor];
    self.invert = [info[@"change_size"] integerValue] < 0;
    
    if ([self showsText]) {
        CGRect textFrame = (CGRect){CGPointZero, self.frame.size};
        textFrame = CGRectInset(textFrame, 5, 0);
        self.textLabel = [[UILabel alloc] initWithFrame:textFrame];
        
        self.textLabel.font = [UIFont systemFontOfSize:17];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        [self.textLabel setMinimumScaleFactor:0.4];
        self.textLabel.text = [info objectForKey:@"page_title"];

        [self addSubview:self.textLabel];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (CGRect)currentFrame
{
//    NSLog(@"---------------");
    NSTimeInterval elapsed = -[self.showTime timeIntervalSinceNow];
//    NSLog(@"elapsed is %f", elapsed);
    CGFloat perc = elapsed / self.duration;
//    NSLog(@"perc is %f", perc);
    CGRect ret = self.initialFrame;
//    NSLog(@"current frame was %@", NSStringFromCGRect(ret));
    ret.origin.x += (self.frame.origin.x - self.initialFrame.origin.x) * perc;
    ret.origin.y += (self.frame.origin.y - self.initialFrame.origin.y) * perc;
    // our width/height don't change, but those would be computed the same way
//    NSLog(@"current frame is %@", NSStringFromCGRect(ret));
    return ret;
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
        dotColor = [UIColor colorWithRed:46.0/255.0
                                   green:204.0/255.0
                                    blue:113.0/255.0
                                   alpha:1];
    }
    else if ([isBot boolValue]) {
        dotColor = [UIColor colorWithRed:155.0/255.0
                                   green:89.0/255.0
                                    blue:182.0/255.0
                                   alpha:1];
    }
    else {
        dotColor = [UIColor whiteColor];
    }
    
    return dotColor;
}

- (BOOL)showsText
{
    if (!self.info) {
        return YES;
    }
    
    NSString *text = [self.info objectForKey:@"page_title"];
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.f*0.4f]}];
    return size.width <= CGRectGetWidth(self.frame);
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
        bgColor = [UIColor blackColor];
    }
    else {
        highlightColor = [UIColor blackColor];
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
    CGContextSetLineWidth(context, 0.5);
    CGRect bounds = CGRectInset(rect, 3, 3);
    CGContextFillEllipseInRect (context, bounds);
    CGContextStrokeEllipseInRect(context, bounds);
    CGContextFillPath(context);
}

@end
