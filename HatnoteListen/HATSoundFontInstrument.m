//
//  HATSoundFontInstrument.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import "HATSoundFontInstrument.h"

@implementation HATSoundFontInstrument

- (HATSoundFontInstrument*)initWithName:(NSString*)name bank:(int)bank program:(int)program {
  self = [super init];
  if (self) {
    self.name = name;
    self.bank = bank;
    self.program = program;
  }

  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ (Bank:%d, Program:%d)", self.name, self.bank, self.program];
}

@end
