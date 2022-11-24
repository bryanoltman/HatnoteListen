//
//  HATWikipediaLanguage.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/16/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATWikipediaLanguage.h"

@implementation HATWikipediaLanguage
- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super init];
  if (!self)
  {
    return nil;
  }

  self.name = [decoder decodeObjectForKey:@"name"];
  self.code = [decoder decodeObjectForKey:@"code"];
  self.websocketURL = [decoder decodeObjectForKey:@"websocketURL"];

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

- (BOOL)isEqual:(HATWikipediaLanguage *)other
{
  if (![other isKindOfClass:[self class]])
  {
    return NO;
  }

  return [self.name isEqualToString:other.name];
}

@end
