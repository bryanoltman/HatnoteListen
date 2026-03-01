//
//  HATWikipediaLanguage.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/16/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATWikipediaLanguage.h"

@implementation HATWikipediaLanguage

+ (NSDictionary*)languageNamesToCodes {
  NSDictionary* langs = nil;
  if (!langs) {
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

+ (NSURL*)websocketURLForLanguageCode:(NSString*)languageCode {
  static NSString* urlBase = @"wss://wikimon.hatnote.com/v2/";
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlBase, languageCode]];
}

- (id)initWithCoder:(NSCoder*)decoder {
  self = [super init];
  if (!self) {
    return nil;
  }

  self.name = [decoder decodeObjectForKey:@"name"];
  self.code = [decoder decodeObjectForKey:@"code"];

  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:self.name forKey:@"name"];
  [encoder encodeObject:self.code forKey:@"code"];
  [encoder encodeObject:self.websocketURL forKey:@"websocketURL"];
}

- (NSComparisonResult)compare:(HATWikipediaLanguage*)other {
  return [self.name compare:other.name];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@ (%@)", self.name, self.websocketURL];
}

- (NSURL*)websocketURL {
  return [HATWikipediaLanguage websocketURLForLanguageCode:self.code];
}

- (BOOL)isEqual:(HATWikipediaLanguage*)other {
  if (![other isKindOfClass:[self class]]) {
    return NO;
  }

  return [self.name isEqualToString:other.name];
}

@end
