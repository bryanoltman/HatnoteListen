//
//  CALayer+Util.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 6/4/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Util)
- (void)pauseAnimations;
- (void)restartAnimations;
- (void)resumeAnimations;
@end
