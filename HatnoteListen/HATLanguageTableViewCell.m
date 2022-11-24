//
//  HATLanguageTableViewCell.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/15/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATLanguageTableViewCell.h"

@implementation HATLanguageTableViewCell

+ (NSString *)reuseId
{
  static NSString *ret = @"HATLanguageTableViewCell";
  return ret;
}

- (void)setLanguage:(HATWikipediaLanguage *)language
{
  _language = language;
  self.languageNameLabel.text = language.name;
  self.toggleSwitch.on =
      [[[HATSettings sharedSettings] selectedLanguages] any:^BOOL(HATWikipediaLanguage *lang) {
        return [lang isEqual:language];
      }];
}

- (void)toggleSwitchToggled
{
  if (self.toggleSwitch.on)
  {
    [[HATSettings sharedSettings] addSelectedLanguage:self.language];
  }
  else
  {
    [[HATSettings sharedSettings] removeSelectedLanguage:self.language];
  }
}

@end
