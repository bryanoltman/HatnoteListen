//
//  HATAboutViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/17/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, HATAboutScreenContent) {
  HATAboutScreenContentWelcome,
  HATAboutScreenContentTutorial,
  HATAboutScreenContentAbout
};

@interface HATAboutViewController : UIViewController

@property (nonatomic) HATAboutScreenContent contentType;

- (void)show:(HATAboutScreenContent)content;

- (void)hide:(void (^)(void))complated;

@end
