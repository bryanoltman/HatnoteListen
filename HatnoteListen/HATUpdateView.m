//
//  HATUpdateView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATUpdateView.h"

@implementation HATUpdateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self
                 action:@selector(didTouchButton)
       forControlEvents:UIControlEventTouchUpInside];
        
        if ([self showsText]) {
            CGRect textFrame = (CGRect){CGPointZero, frame.size};
            textFrame = CGRectInset(textFrame, 3, 0);
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

- (void)didTouchButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bubbleClicked" object:self.info];
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    self.textLabel.text = [info objectForKey:@"page_title"];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
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
