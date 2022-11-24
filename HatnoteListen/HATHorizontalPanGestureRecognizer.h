//
//  HATHorizontalPanGestureRecognizer.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/20/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import <UIKit/UIKit.h>

typedef enum
{
  DirectionPangestureRecognizerVertical,
  DirectionPanGestureRecognizerHorizontal
} DirectionPangestureRecognizerDirection;

@interface HATHorizontalPanGestureRecognizer : UIPanGestureRecognizer
{
  BOOL _drag;
  int _moveX;
  int _moveY;
  DirectionPangestureRecognizerDirection _direction;
}

@property (nonatomic, assign) DirectionPangestureRecognizerDirection direction;

@end
