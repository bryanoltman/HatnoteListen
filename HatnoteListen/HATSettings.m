//
//  HATSettings.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/10/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATSettings.h"

#define SettingsKey (@"SettingsKey")
#define SelectedLanguagesKey (@"SelectedLanguagesKey")
#define SoundsMutedKey (@"SoundsMutedKey")
#define TextVolumeKey (@"TextVolumeKey")

@interface HATSettings ()
@property (strong, nonatomic) NSMutableArray *selectedLanguagesMutable;
@end

@implementation HATSettings

+ (instancetype)sharedSettings
{
  static HATSettings *instance = nil;
  if (!instance)
  {
    instance = [[HATSettings alloc] init];
  }

  return instance;
}

- (id)init
{
  self = [super init];
  if (self)
  {
    self.selectedLanguagesMutable = self.settings[SelectedLanguagesKey];
    if (!self.selectedLanguages)
    {
      HATWikipediaLanguage *englishLanguage =
          [[HATSettings availableLanguages] find:^BOOL(HATWikipediaLanguage *lang) {
            return [lang.code isEqualToString:@"en"];
          }];

      self.selectedLanguagesMutable = [@[ englishLanguage ] mutableCopy];
    }

    self.soundsMuted = [self.settings[SoundsMutedKey] boolValue] ?: NO;
    self.textVolume = [self.settings[TextVolumeKey] intValue] ?: HATTextVolumeLots;
  }

  return self;
}

- (NSMutableDictionary *)settings
{
  static NSMutableDictionary *settings = nil;
  if (!settings)
  {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SettingsKey];
    if (data)
    {
      settings = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
  }

  if (!settings)
  {
    settings = [[NSMutableDictionary alloc] init];
  }

  return settings;
}

- (void)save
{
  //    NSLog(@"saving settings: %@", [self settings]);
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self settings]];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:SettingsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)selectedLanguages
{
  return self.selectedLanguagesMutable;
}

- (void)addSelectedLanguage:(HATWikipediaLanguage *)lang
{
  NSIndexSet *index = [NSIndexSet indexSetWithIndex:[self.selectedLanguagesMutable count]];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"selectedLanguages"];
  [self.selectedLanguagesMutable addObject:lang];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"selectedLanguages"];

  [self.settings setObject:self.selectedLanguagesMutable forKey:SelectedLanguagesKey];
  [self save];
}

- (void)removeSelectedLanguage:(HATWikipediaLanguage *)lang
{
  if (![self.selectedLanguagesMutable containsObject:lang])
  {
    return;
  }

  NSIndexSet *index =
      [NSIndexSet indexSetWithIndex:[self.selectedLanguagesMutable indexOfObject:lang]];
  [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"selectedLanguages"];
  [self.selectedLanguagesMutable removeObject:lang];
  [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"selectedLanguages"];

  [self save];
}

+ (NSArray *)availableLanguages
{
  static NSMutableArray *ret = nil;
  if (!ret)
  {
    ret = [NSMutableArray new];
    [[HATWikipediaLanguage languageNamesToCodes]
        enumerateKeysAndObjectsUsingBlock:^(NSString *languageName, NSString *languageCode, BOOL *stop) {
          HATWikipediaLanguage *lang = [HATWikipediaLanguage new];
          lang.name = languageName;
          lang.code = languageCode;
          [ret addObject:lang];
        }];
  }

  return [ret sortedArrayUsingSelector:@selector(compare:)];
}

- (void)setSoundsMuted:(BOOL)soundsMuted
{
  if (soundsMuted == _soundsMuted)
  {
    return;
  }

  //    [Flurry logEvent:@"volume_toggled"
  //      withParameters:@{@"on" : @(!soundsMuted)}];

  _soundsMuted = soundsMuted;
  [self.settings setObject:@(soundsMuted) forKey:SoundsMutedKey];
  [self save];
}

- (void)setTextVolume:(HATTextVolume)textVolume
{
  if (textVolume == _textVolume)
  {
    return;
  }

  //    [Flurry logEvent:@"text_volume_changed"
  //      withParameters:@{@"volume" : @(textVolume)}];

  _textVolume = textVolume;
  [self.settings setObject:@(textVolume) forKey:TextVolumeKey];
  [self save];
}

@end
