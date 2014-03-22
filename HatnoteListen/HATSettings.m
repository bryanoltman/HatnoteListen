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

+ (NSDictionary *)languageUrlMap
{
    static NSDictionary *langs = nil;
    if (!langs) {
        langs = @{
                  @"en":  @"ws://wikimon.hatnote.com:9000",
                  @"de":  @"ws://wikimon.hatnote.com:9010",
                  @"ru":  @"ws://wikimon.hatnote.com:9020",
                  @"uk":  @"ws://wikimon.hatnote.com:9310",
                  @"ja":  @"ws://wikimon.hatnote.com:9030",
                  @"es":  @"ws://wikimon.hatnote.com:9040",
                  @"fr":  @"ws://wikimon.hatnote.com:9050",
                  @"nl":  @"ws://wikimon.hatnote.com:9060",
                  @"it":  @"ws://wikimon.hatnote.com:9070",
                  @"sv":  @"ws://wikimon.hatnote.com:9080",
                  @"ar":  @"ws://wikimon.hatnote.com:9090",
                  @"fa":  @"ws://wikimon.hatnote.com:9210",
                  @"he":  @"ws://wikimon.hatnote.com:9230",
                  @"id":  @"ws://wikimon.hatnote.com:9100",
                  @"zh":  @"ws://wikimon.hatnote.com:9240",
                  @"as":  @"ws://wikimon.hatnote.com:9150",
                  @"hi":  @"ws://wikimon.hatnote.com:9140",
                  @"bn":  @"ws://wikimon.hatnote.com:9160",
                  @"pa":  @"ws://wikimon.hatnote.com:9120",
                  @"te":  @"ws://wikimon.hatnote.com:9160",
                  @"ta":  @"ws://wikimon.hatnote.com:9110",
                  @"ml":  @"ws://wikimon.hatnote.com:9250",
                  @"mr":  @"ws://wikimon.hatnote.com:9130",
                  @"kn":  @"ws://wikimon.hatnote.com:9170",
                  @"or":  @"ws://wikimon.hatnote.com:9180",
                  @"sa":  @"ws://wikimon.hatnote.com:9190",
                  @"gu":  @"ws://wikimon.hatnote.com:9200",
                  @"pl":  @"ws://wikimon.hatnote.com:9260",
                  @"mk":  @"ws://wikimon.hatnote.com:9270",
                  @"be":  @"ws://wikimon.hatnote.com:9280",
                  @"bg":  @"ws://wikimon.hatnote.com:9300",
                  @"sr":  @"ws://wikimon.hatnote.com:9290",
                  @"wikidata": @"ws://wikimon.hatnote.com:9220"
                  };
    }
    
    return langs;
}

+ (NSDictionary *)languageNameMap
{
    NSDictionary *langs = nil;
    if (!langs) {
        langs = @{
                  @"English" :   @"en",
                  @"German" :   @"de",
                  @"Russian" :   @"ru",
                  @"Ukrainian" :   @"uk",
                  @"Japanese" :   @"ja",
                  @"Spanish" :   @"es",
                  @"French" :   @"fr",
                  @"Dutch" :   @"nl",
                  @"Italian" :   @"it",
                  @"Swedish" :   @"sv",
                  @"Arabic" :   @"ar",
                  @"Farsi" :   @"fa",
                  @"Hebrew" :   @"he",
                  @"Indonesian" :   @"id",
                  @"Chinese" :   @"zh",
                  @"Assamese" :   @"as",
                  @"Hindi" :   @"hi",
                  @"Bengali" :   @"bn",
                  @"Punjabi" :   @"pa",
                  @"Telugu" :   @"te",
                  @"Tamil" :   @"ta",
                  @"Malayalam" :   @"ml",
                  @"Western Mari" :   @"mr",
                  @"Kannada" :   @"kn",
                  @"Oriya" :   @"or",
                  @"Sanskrit" :   @"sa",
                  @"Gujarati" :   @"gu",
                  @"Polish"  :   @"pl",
                  @"Macedonian" :   @"mk",
                  @"Belarusian" :   @"be",
                  @"Bulgarian" :   @"bg",
                  @"Serbian" :   @"sr",
                  };
    }
    
    return langs;
}

+ (instancetype)sharedSettings
{
    static HATSettings *instance = nil;
    if (!instance) {
        instance = [HATSettings new];
    }
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.selectedLanguagesMutable = self.settings[SelectedLanguagesKey];
        if (!self.selectedLanguages) {
            HATWikipediaLanguage *englishLanguage = [[HATSettings availableLanguages] find:^BOOL(HATWikipediaLanguage *lang) {
                return [lang.code isEqualToString:@"en"];
            }];
            
            self.selectedLanguagesMutable = [@[englishLanguage] mutableCopy];
        }
        
        self.soundsMuted = [self.settings[SoundsMutedKey] boolValue];
        self.textVolume = [self.settings[TextVolumeKey] intValue];
    }
    
    return self;
}

- (NSMutableDictionary *)settings
{
    static NSMutableDictionary *settings = nil;
    if (!settings) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SettingsKey];
        settings = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (!settings) {
        settings = [NSMutableDictionary new];
    }
    
    return settings;
}

- (void)save
{
    NSLog(@"saving settings: %@", [self settings]);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self settings]];
    [[NSUserDefaults standardUserDefaults] setObject:data
                                              forKey:SettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)objectForSettingsKey:(NSString *)key
{
    JSONDecoder *decoder = [JSONDecoder new];
    NSString *json = self.settings[SelectedLanguagesKey];
    if (!json) {
        return nil;
    }
    
    return [decoder objectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSArray *)selectedLanguages
{
    return self.selectedLanguagesMutable;
}

- (void)addSelectedLanguage:(HATWikipediaLanguage *)lang
{
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:[self.selectedLanguagesMutable count]];
    [self willChange:NSKeyValueChangeInsertion
     valuesAtIndexes:index
              forKey:@"selectedLanguages"];
    [self.selectedLanguagesMutable addObject:lang];
    [self didChange:NSKeyValueChangeInsertion
    valuesAtIndexes:index
             forKey:@"selectedLanguages"];
    
    [self.settings setObject:self.selectedLanguagesMutable forKey:SelectedLanguagesKey];
    [self save];
}

- (void)removeSelectedLanguage:(HATWikipediaLanguage *)lang
{
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:[self.selectedLanguagesMutable indexOfObject:lang]];
    [self willChange:NSKeyValueChangeRemoval
     valuesAtIndexes:index
              forKey:@"selectedLanguages"];
    [self.selectedLanguagesMutable removeObject:lang];
    [self didChange:NSKeyValueChangeRemoval 
    valuesAtIndexes:index
             forKey:@"selectedLanguages"];

    [self save];
}

+ (NSArray *)availableLanguages
{
    static NSMutableArray *ret = nil;
    if (!ret) {
        ret = [NSMutableArray new];
        [[self languageNameMap] enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *code, BOOL *stop) {
            HATWikipediaLanguage *lang = [HATWikipediaLanguage new];
            lang.name = name;
            lang.code = code;
            lang.websocketURL = [NSURL URLWithString:[self languageUrlMap][code]];
            [ret addObject:lang];
        }];
    }
    
    return [ret sortedArrayUsingSelector:@selector(compare:)];
}

- (void)setSoundsMuted:(BOOL)soundsMuted
{
    if (soundsMuted == _soundsMuted) {
        return;
    }
    
    _soundsMuted = soundsMuted;
    [self.settings setObject:@(soundsMuted) forKey:SoundsMutedKey];
    [self save];
}

- (void)setTextVolume:(HATTextVolume)textVolume
{
    if (textVolume == _textVolume) {
        return;
    }
    
    _textVolume = textVolume;
    [self.settings setObject:@(textVolume) forKey:TextVolumeKey];
    [self save];
}

@end
