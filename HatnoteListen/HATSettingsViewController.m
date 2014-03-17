//
//  HATSettingsViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/10/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATSettingsViewController.h"

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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[HATSettings availableLanguages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < [[HATSettings availableLanguages] count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[HATLanguageTableViewCell reuseId]];
        HATLanguageTableViewCell *hatLanguageCell = (HATLanguageTableViewCell *)cell;
        hatLanguageCell.language = [HATSettings availableLanguages][[indexPath row]];
    }

    return cell;
}

@end
