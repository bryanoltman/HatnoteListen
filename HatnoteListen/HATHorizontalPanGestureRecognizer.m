//
//  HATHorizontalPanGestureRecognizer.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/20/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATHorizontalPanGestureRecognizer.h"

@implementation HATHorizontalPanGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_drag) {
        if (abs(_moveX) > abs(_moveY)) {
            if (_direction == DirectionPangestureRecognizerVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }
            else {
                _drag = YES;
            }
        }
        else if (abs(_moveY) > abs(_moveX)) {
            if (_direction == DirectionPanGestureRecognizerHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }
            else {
                _drag = YES;
            }
        }
    }
}

- (void)reset
{
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
