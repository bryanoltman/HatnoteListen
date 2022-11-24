//
//  HATAppDelegate.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HATSettingsViewController.h"
#import "HATSidePanelController.h"
#import "HATViewController.h"

@interface HATAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HATSidePanelController *container;
@property (strong, nonatomic) HATViewController *viewController;
@property (strong, nonatomic) HATSettingsViewController *settingsViewController;

@end
