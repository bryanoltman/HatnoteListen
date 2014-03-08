//
//  HATUpdateView.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HATUpdateView : UIView

@property (nonatomic) BOOL highlighted;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) NSInteger magnitude;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) UILabel *textLabel;
@property (nonatomic) BOOL invert;
@property (nonatomic) CGFloat duration;
@property (strong, nonatomic) NSDate *showTime;

- (CGRect)currentFrame;

@end
