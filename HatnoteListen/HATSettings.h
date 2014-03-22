//
//  HATSettings.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/10/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HATWikipediaLanguage.h"

@interface HATSettings : NSObject
+ (instancetype)sharedSettings;

@property (nonatomic) BOOL soundsMuted;

+ (NSArray *)availableLanguages;
- (NSArray *)selectedLanguages;
- (void)addSelectedLanguage:(HATWikipediaLanguage *)lang;
- (void)removeSelectedLanguage:(HATWikipediaLanguage *)lang;
@end
