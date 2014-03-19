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
    
    self.container = [[JSSlidingViewController alloc] initWithFrontViewController:self.viewController
                                                               backViewController:self.settingsViewController];
    self.container.delegate = self;
    self.container.useParallaxMotionEffect = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.container;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.container setWidthOfVisiblePortionOfFrontViewControllerWhenSliderIsOpen:30];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)slidingViewControllerWillOpen:(JSSlidingViewController *)viewController
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)slidingViewControllerDidOpen:(JSSlidingViewController *)viewController
{
    [[self viewController] hideAboutView];
}

- (void)slidingViewControllerWillClose:(JSSlidingViewController *)viewController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
