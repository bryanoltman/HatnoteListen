//
//  HATLanguageTableViewCell.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/15/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HATWikipediaLanguage.h"

@interface HATLanguageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *languageNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@property (strong, nonatomic) HATWikipediaLanguage *language;

+ (NSString *)reuseId;

- (IBAction)toggleSwitchToggled;

@end
