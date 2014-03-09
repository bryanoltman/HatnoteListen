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
@end

@implementation HATUpdateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.initialFrame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        if ([self showsText]) {
            CGRect textFrame = (CGRect){CGPointZero, frame.size};
            textFrame = CGRectInset(textFrame, 5, 0);
            self.textLabel = [[UILabel alloc] initWithFrame:textFrame];

            CGFloat fontSize = frame.size.width / 10;
            self.textLabel.font = [UIFont systemFontOfSize:fontSize];
            
            self.textLabel.textAlignment = NSTextAlignmentCenter;
            self.textLabel.adjustsFontSizeToFitWidth = YES;
            [self.textLabel setMinimumScaleFactor:0.1];
            
            [self addSubview:self.textLabel];
        }
    }
    
    return self;
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    self.textLabel.text = [info objectForKey:@"page_title"];
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

- (BOOL)showsText
{
    return CGRectGetWidth(self.frame) > 40;
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
