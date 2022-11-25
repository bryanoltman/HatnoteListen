//
//  HATWikipediaViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATWikipediaViewController.h"

@interface HATWikipediaViewController ()

@end

@implementation HATWikipediaViewController

- (void)setInfo:(NSDictionary *)info
{
  _info = info;
  self.textLabel.text = info[@"page_title"];
}

- (IBAction)viewTapped:(id)sender
{
  [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:self.info[@"url"]]
                options:@{}
      completionHandler:nil];
}

@end
