//
//  HATWikipediaViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HATWikipediaViewController : UIViewController

@property (strong, nonatomic) NSDictionary *info;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

- (IBAction)viewTapped:(id)sender;

@end
