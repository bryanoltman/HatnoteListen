//
//  CALayer+Util.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 6/4/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "CALayer+Util.h"

@implementation CALayer (Util)
-(void)pauseAnimations
{
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

- (void)restartAnimations
{
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    self.beginTime = CACurrentMediaTime();
}

-(void)resumeAnimations
{
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

@end
