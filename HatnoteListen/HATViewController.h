//
//  HATViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface HATViewController : UIViewController <AVAudioPlayerDelegate, SRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

- (IBAction)muteButtonClicked:(id)sender;

@end
