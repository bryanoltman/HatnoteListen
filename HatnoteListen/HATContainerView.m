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
    NSMutableArray *hitViews = [NSMutableArray new];
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:[HATUpdateView class]]) {
            continue;
        }
        
        HATUpdateView *view = (HATUpdateView *)subview;
        if (CGRectContainsPoint([view frame], point)) {
            [hitViews addObject:view];
        }
    }
    
    self.highlightedView = [hitViews minimum:^id(HATUpdateView *view) {
        return view.lastTouchDate;
    }];
    
    if (self.highlightedView) {
        self.highlightedView.lastTouchDate = [NSDate date];
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

    if (!CGRectContainsPoint(self.highlightedView.frame, point)) {
        self.highlightedView.highlighted = NO;
        self.highlightedView = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];

    if (self.highlightedView && CGRectContainsPoint(self.highlightedView.frame, point)) {
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
