//
//  HATWikipediaLanguage.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/16/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATWikipediaLanguage.h"

@implementation HATWikipediaLanguage
+ (NSDictionary *)languageUrlMap
{
  static NSDictionary *langs = nil;
  if (!langs)
  {
    langs = @{
      @"en" : @"ws://wikimon.hatnote.com:9000",
      @"de" : @"ws://wikimon.hatnote.com:9010",
      @"ru" : @"ws://wikimon.hatnote.com:9020",
      @"uk" : @"ws://wikimon.hatnote.com:9310",
      @"ja" : @"ws://wikimon.hatnote.com:9030",
      @"es" : @"ws://wikimon.hatnote.com:9040",
      @"fr" : @"ws://wikimon.hatnote.com:9050",
      @"nl" : @"ws://wikimon.hatnote.com:9060",
      @"it" : @"ws://wikimon.hatnote.com:9070",
      @"sv" : @"ws://wikimon.hatnote.com:9080",
      @"ar" : @"ws://wikimon.hatnote.com:9090",
      @"fa" : @"ws://wikimon.hatnote.com:9210",
      @"he" : @"ws://wikimon.hatnote.com:9230",
      @"id" : @"ws://wikimon.hatnote.com:9100",
      @"zh" : @"ws://wikimon.hatnote.com:9240",
      @"as" : @"ws://wikimon.hatnote.com:9150",
      @"hi" : @"ws://wikimon.hatnote.com:9140",
      @"bn" : @"ws://wikimon.hatnote.com:9160",
      @"pa" : @"ws://wikimon.hatnote.com:9120",
      @"te" : @"ws://wikimon.hatnote.com:9160",
      @"ta" : @"ws://wikimon.hatnote.com:9110",
      @"ml" : @"ws://wikimon.hatnote.com:9250",
      @"mr" : @"ws://wikimon.hatnote.com:9130",
      @"kn" : @"ws://wikimon.hatnote.com:9170",
      @"or" : @"ws://wikimon.hatnote.com:9180",
      @"sa" : @"ws://wikimon.hatnote.com:9190",
      @"gu" : @"ws://wikimon.hatnote.com:9200",
      @"pl" : @"ws://wikimon.hatnote.com:9260",
      @"mk" : @"ws://wikimon.hatnote.com:9270",
      @"be" : @"ws://wikimon.hatnote.com:9280",
      @"bg" : @"ws://wikimon.hatnote.com:9300",
      @"sr" : @"ws://wikimon.hatnote.com:9290",
      @"wikidata" : @"ws://wikimon.hatnote.com:9220"
    };
  }

  return langs;
}

+ (NSDictionary *)languageNamesToCodes
{
  NSDictionary *langs = nil;
  if (!langs)
  {
    langs = @{
      @"English" : @"en",
      @"German" : @"de",
      @"Russian" : @"ru",
      @"Ukrainian" : @"uk",
      @"Japanese" : @"ja",
      @"Spanish" : @"es",
      @"French" : @"fr",
      @"Dutch" : @"nl",
      @"Italian" : @"it",
      @"Swedish" : @"sv",
      @"Arabic" : @"ar",
      @"Farsi" : @"fa",
      @"Hebrew" : @"he",
      @"Indonesian" : @"id",
      @"Chinese" : @"zh",
      @"Assamese" : @"as",
      @"Hindi" : @"hi",
      @"Bengali" : @"bn",
      @"Punjabi" : @"pa",
      @"Telugu" : @"te",
      @"Tamil" : @"ta",
      @"Malayalam" : @"ml",
      @"Western Mari" : @"mr",
      @"Kannada" : @"kn",
      @"Oriya" : @"or",
      @"Sanskrit" : @"sa",
      @"Gujarati" : @"gu",
      @"Polish" : @"pl",
      @"Macedonian" : @"mk",
      @"Belarusian" : @"be",
      @"Bulgarian" : @"bg",
      @"Serbian" : @"sr",
    };
  }

  return langs;
}

+ (NSURL *)websocketURLForLanguageCode:(NSString *)languageCode
{
  NSString *urlString = [self languageUrlMap][languageCode];
  if (!urlString)
  {
    return nil;
  }
  return [NSURL URLWithString:urlString];
}

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super init];
  if (!self)
  {
    return nil;
  }

  self.name = [decoder decodeObjectForKey:@"name"];
  self.code = [decoder decodeObjectForKey:@"code"];

  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeObject:self.name forKey:@"name"];
  [encoder encodeObject:self.code forKey:@"code"];
  [encoder encodeObject:self.websocketURL forKey:@"websocketURL"];
}

- (NSComparisonResult)compare:(HATWikipediaLanguage *)other
{
  return [self.name compare:other.name];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ (%@)", self.name, self.websocketURL];
}

- (NSURL *)websocketURL
{
  return [HATWikipediaLanguage websocketURLForLanguageCode:self.code];
}

- (BOOL)isEqual:(HATWikipediaLanguage *)other
{
  if (![other isKindOfClass:[self class]])
  {
    return NO;
  }

  return [self.name isEqualToString:other.name];
}

@end
