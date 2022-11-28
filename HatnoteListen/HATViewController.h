//
//  HATViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBKVOController.h"
#import "HATAboutViewController.h"

int indexForChangeSize(double changeSize);

@interface HATViewController : UIViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) HATAboutViewController *aboutVC;

- (void)showAboutView:(HATAboutScreenContent)content;
- (void)hideAboutView;

@end
