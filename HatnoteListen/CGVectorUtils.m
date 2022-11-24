//
//  CGVectorUtils.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 6/7/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "CGVectorUtils.h"

CGFloat CGVectorLength(CGVector vector)
{
  return sqrtf(vector.dx * vector.dx + vector.dy * vector.dy);
}

CGVector CGVectorDirection(CGVector vector)
{
  CGFloat length = CGVectorLength(vector);
  return CGVectorMake(vector.dx / length, vector.dy / length);
}