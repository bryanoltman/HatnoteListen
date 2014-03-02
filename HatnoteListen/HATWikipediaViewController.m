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
    self.textLabel.text = [info objectForKey:@"page_title"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:self.view.bounds];
    bar.barStyle = UIBarStyleBlack;
    bar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:bar atIndex:0];
}

- (IBAction)viewTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.info objectForKey:@"url"]]];
}

@end
