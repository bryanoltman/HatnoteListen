//
//  HATSettings.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/10/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HATWikipediaLanguage.h"

typedef NS_OPTIONS(NSUInteger, HATTextVolume) {
    HATTextVolumeNone,
    HATTextVolumeSome,
    HATTextVolumeLots,
    HATTextVolumeAll,
    HATTextVolumeCount
};

@interface HATSettings : NSObject
+ (instancetype)sharedSettings;

@property (nonatomic) BOOL soundsMuted;
@property (nonatomic) HATTextVolume textVolume;

+ (NSArray *)availableLanguages;
- (NSArray *)selectedLanguages;
- (void)addSelectedLanguage:(HATWikipediaLanguage *)lang;
- (void)removeSelectedLanguage:(HATWikipediaLanguage *)lang;
@end
