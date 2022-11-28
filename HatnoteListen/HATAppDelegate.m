//
//  HATAppDelegate.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATAppDelegate.h"

@implementation HATAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [UIApplication sharedApplication].idleTimerDisabled = YES;

  //    [Flurry setCrashReportingEnabled:YES];
  //    [Flurry startSession:@"393H7GGNJSBGMS64K6T9"];

  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

  NSError *error = nil;
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  if (error) {
    NSLog(@"Error configuring AVAudioSession: %@", error);
  }

  self.sidePanelController = [HATSidePanelController new];
  self.viewController = [[UIStoryboard storyboardWithName:@"Main"
                                                   bundle:nil] instantiateInitialViewController];
  self.settingsViewController =
      [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateInitialViewController];
  self.sidePanelController.leftPanel = self.settingsViewController;
  self.sidePanelController.centerPanel = self.viewController;
  self.sidePanelController.bounceOnSidePanelOpen = NO;

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = self.sidePanelController;
  [self.window makeKeyAndVisible];

  return YES;
}

@end
