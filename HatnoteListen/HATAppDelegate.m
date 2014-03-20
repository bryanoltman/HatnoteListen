//
//  HATAppDelegate.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATAppDelegate.h"

@implementation HATAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayback
     error:nil];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    
    self.settingsViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateInitialViewController];
    
    self.container = [HATSidePanelController new];
    self.container.leftPanel = self.settingsViewController;
    self.container.centerPanel = self.viewController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.container;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
