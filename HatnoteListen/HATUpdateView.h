//
//  HATUpdateView.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/24/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HATUpdateView : UIButton

@property (strong, nonatomic) UIColor *color;
@property (nonatomic) NSInteger magnitude;
@property (strong, nonatomic) NSString *title;
@property (nonatomic) BOOL selected;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) UILabel *textLabel;

@end
