//
//  HATNote.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import "HATNote.h"

@implementation HATNote

+ (NSArray<NSNumber*>*)scaleFromRootNote:(HATMIDINote)rootNote
                                    mode:(HATMusicalMode)mode
                                 octaves:(NSUInteger)octaves {
  // 1. Define the semitone intervals for each mode
  // (A standard diatonic scale has 7 intervals)
  static const NSInteger ionian[] = {2, 2, 1, 2, 2, 2, 1};
  static const NSInteger dorian[] = {2, 1, 2, 2, 2, 1, 2};
  static const NSInteger phrygian[] = {1, 2, 2, 2, 1, 2, 2};
  static const NSInteger lydian[] = {2, 2, 2, 1, 2, 2, 1};
  static const NSInteger mixolydian[] = {2, 2, 1, 2, 2, 1, 2};
  static const NSInteger aeolian[] = {2, 1, 2, 2, 1, 2, 2};
  static const NSInteger locrian[] = {1, 2, 2, 1, 2, 2, 2};

  // 2. Select the correct interval pattern based on the requested mode
  const NSInteger* intervals;
  switch (mode) {
    case MusicalModeIonian:
      intervals = ionian;
      break;
    case MusicalModeDorian:
      intervals = dorian;
      break;
    case MusicalModePhrygian:
      intervals = phrygian;
      break;
    case MusicalModeLydian:
      intervals = lydian;
      break;
    case MusicalModeMixolydian:
      intervals = mixolydian;
      break;
    case MusicalModeAeolian:
      intervals = aeolian;
      break;
    case MusicalModeLocrian:
      intervals = locrian;
      break;
  }

  // 3. Build the scale array
  NSMutableArray<NSNumber*>* scaleNotes = [NSMutableArray array];

  // Add the root note as the first element
  NSInteger currentNote = rootNote;
  [scaleNotes addObject:@(currentNote)];

  // 4. Loop through the requested number of octaves
  for (NSUInteger octave = 0; octave < octaves; octave++) {
    // Loop through the 7 intervals of the mode
    for (NSInteger step = 0; step < 7; step++) {
      currentNote += intervals[step];

      // Safety check: Ensure we don't exceed the maximum MIDI note (127)
      if (currentNote > 127) {
        return [scaleNotes copy];
      }

      [scaleNotes addObject:@(currentNote)];
    }
  }

  return [scaleNotes copy];
}

@end
