//
//  HATSettingsViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/10/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATSettingsViewController.h"

#define kLanguageSection 0
#define kAboutSection 1

@implementation HATSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kLanguageSection:
            return [[HATSettings availableLanguages] count];
        case kAboutSection:
            return 1;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == kLanguageSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:[HATLanguageTableViewCell reuseId]];
        HATLanguageTableViewCell *hatLanguageCell = (HATLanguageTableViewCell *)cell;
        hatLanguageCell.language = [HATSettings availableLanguages][[indexPath row]];
    }
    else if (indexPath.section == kAboutSection) {
        static NSString *reuseId = @"HATAboutCell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kLanguageSection) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kAboutSection) {
        [[appDelegate viewController] showAboutView];
    }
}

@end
