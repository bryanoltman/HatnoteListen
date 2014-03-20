//
//  HATSidePanelViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/19/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATSidePanelController.h"

@implementation HATSidePanelController

- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds
                                                          cornerRadius:0.0f];
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        animation.fromValue = (id)container.layer.shadowPath;
        animation.toValue = (id)shadowPath.CGPath;
        animation.duration = duration;
        [container.layer addAnimation:animation forKey:@"shadowPath"];
    }
    
    container.layer.shadowPath = shadowPath.CGPath;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 5.0f;
    container.layer.shadowOpacity = 0.666f;
    container.clipsToBounds = NO;
}

@end
