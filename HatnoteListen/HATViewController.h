//
//  HATViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import "FBKVOController.h"
#import "HATAboutViewController.h"

@interface HATViewController : UIViewController <AVAudioPlayerDelegate, SRWebSocketDelegate>

@property (nonatomic) BOOL muted;

@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (strong, nonatomic) IBOutlet UILabel *userLabel; // Strong because we juggle this around in its superview and this is less bug-prone than needing to create a strong reference for it every time
@property (strong, nonatomic) HATAboutViewController *aboutVC;

- (IBAction)muteButtonClicked:(id)sender;
- (IBAction)newUserViewTapped:(id)sender;

- (void)showAboutView;
- (void)hideAboutView;

@end
