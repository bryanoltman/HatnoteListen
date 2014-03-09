//
//  HATUpdateView.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HATUpdateView : UIView

@property (strong, nonatomic) UIColor *color;
@property (nonatomic) BOOL highlighted;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) UILabel *textLabel;
@property (nonatomic) CGFloat duration;
@property (strong, nonatomic) NSDate *showTime;

- (instancetype)initWithFrame:(CGRect)frame andInfo:(NSDictionary *)info;
- (CGRect)currentFrame;

@end
