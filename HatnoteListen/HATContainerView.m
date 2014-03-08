//
//  HATContainerView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/8/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATContainerView.h"
#import "HATUpdateView.h"

@interface HATContainerView ()
@property (weak, nonatomic) HATUpdateView *highlightedView;
@end

@implementation HATContainerView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:[HATUpdateView class]]) {
            continue;
        }
        
        HATUpdateView *view = (HATUpdateView *)subview;
        if (CGRectContainsPoint([view currentFrame], point)) {
            self.highlightedView = view;
            break;
        }
    }
    
    if (self.highlightedView) {
        self.highlightedView.highlighted = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];

    if (!self.highlightedView) {
        return;
    }

    if (!CGRectContainsPoint([self.highlightedView currentFrame], point)) {
        self.highlightedView.highlighted = NO;
        self.highlightedView = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];

    if (self.highlightedView && CGRectContainsPoint([self.highlightedView currentFrame], point)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bubbleClicked"
                                                            object:self.highlightedView.info];
    }
    
    self.highlightedView.highlighted = NO;
    self.highlightedView = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlightedView.highlighted = NO;
    self.highlightedView = nil;
}

@end
