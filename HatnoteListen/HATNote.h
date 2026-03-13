//
//  HATNote.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, HATMIDINote) {
    // Octave -1
    MIDINoteCMinus1      = 0,
    MIDINoteCSharpMinus1 = 1,
    MIDINoteDMinus1      = 2,
    MIDINoteDSharpMinus1 = 3,
    MIDINoteEMinus1      = 4,
    MIDINoteFMinus1      = 5,
    MIDINoteFSharpMinus1 = 6,
    MIDINoteGMinus1      = 7,
    MIDINoteGSharpMinus1 = 8,
    MIDINoteAMinus1      = 9,
    MIDINoteASharpMinus1 = 10,
    MIDINoteBMinus1      = 11,

    // Octave 0
    MIDINoteC0           = 12,
    MIDINoteCSharp0      = 13,
    MIDINoteD0           = 14,
    MIDINoteDSharp0      = 15,
    MIDINoteE0           = 16,
    MIDINoteF0           = 17,
    MIDINoteFSharp0      = 18,
    MIDINoteG0           = 19,
    MIDINoteGSharp0      = 20,
    MIDINoteA0           = 21,
    MIDINoteASharp0      = 22,
    MIDINoteB0           = 23,

    // Octave 1
    MIDINoteC1           = 24,
    MIDINoteCSharp1      = 25,
    MIDINoteD1           = 26,
    MIDINoteDSharp1      = 27,
    MIDINoteE1           = 28,
    MIDINoteF1           = 29,
    MIDINoteFSharp1      = 30,
    MIDINoteG1           = 31,
    MIDINoteGSharp1      = 32,
    MIDINoteA1           = 33,
    MIDINoteASharp1      = 34,
    MIDINoteB1           = 35,

    // Octave 2
    MIDINoteC2           = 36,
    MIDINoteCSharp2      = 37,
    MIDINoteD2           = 38,
    MIDINoteDSharp2      = 39,
    MIDINoteE2           = 40,
    MIDINoteF2           = 41,
    MIDINoteFSharp2      = 42,
    MIDINoteG2           = 43,
    MIDINoteGSharp2      = 44,
    MIDINoteA2           = 45,
    MIDINoteASharp2      = 46,
    MIDINoteB2           = 47,

    // Octave 3
    MIDINoteC3           = 48,
    MIDINoteCSharp3      = 49,
    MIDINoteD3           = 50,
    MIDINoteDSharp3      = 51,
    MIDINoteE3           = 52,
    MIDINoteF3           = 53,
    MIDINoteFSharp3      = 54,
    MIDINoteG3           = 55,
    MIDINoteGSharp3      = 56,
    MIDINoteA3           = 57,
    MIDINoteASharp3      = 58,
    MIDINoteB3           = 59,

    // Octave 4 (Middle Octave)
    MIDINoteC4           = 60, // Middle C
    MIDINoteCSharp4      = 61,
    MIDINoteD4           = 62,
    MIDINoteDSharp4      = 63,
    MIDINoteE4           = 64,
    MIDINoteF4           = 65,
    MIDINoteFSharp4      = 66,
    MIDINoteG4           = 67,
    MIDINoteGSharp4      = 68,
    MIDINoteA4           = 69, // Concert A (440 Hz)
    MIDINoteASharp4      = 70,
    MIDINoteB4           = 71,

    // Octave 5
    MIDINoteC5           = 72,
    MIDINoteCSharp5      = 73,
    MIDINoteD5           = 74,
    MIDINoteDSharp5      = 75,
    MIDINoteE5           = 76,
    MIDINoteF5           = 77,
    MIDINoteFSharp5      = 78,
    MIDINoteG5           = 79,
    MIDINoteGSharp5      = 80,
    MIDINoteA5           = 81,
    MIDINoteASharp5      = 82,
    MIDINoteB5           = 83,

    // Octave 6
    MIDINoteC6           = 84,
    MIDINoteCSharp6      = 85,
    MIDINoteD6           = 86,
    MIDINoteDSharp6      = 87,
    MIDINoteE6           = 88,
    MIDINoteF6           = 89,
    MIDINoteFSharp6      = 90,
    MIDINoteG6           = 91,
    MIDINoteGSharp6      = 92,
    MIDINoteA6           = 93,
    MIDINoteASharp6      = 94,
    MIDINoteB6           = 95,

    // Octave 7
    MIDINoteC7           = 96,
    MIDINoteCSharp7      = 97,
    MIDINoteD7           = 98,
    MIDINoteDSharp7      = 99,
    MIDINoteE7           = 100,
    MIDINoteF7           = 101,
    MIDINoteFSharp7      = 102,
    MIDINoteG7           = 103,
    MIDINoteGSharp7      = 104,
    MIDINoteA7           = 105,
    MIDINoteASharp7      = 106,
    MIDINoteB7           = 107,

    // Octave 8
    MIDINoteC8           = 108,
    MIDINoteCSharp8      = 109,
    MIDINoteD8           = 110,
    MIDINoteDSharp8      = 111,
    MIDINoteE8           = 112,
    MIDINoteF8           = 113,
    MIDINoteFSharp8      = 114,
    MIDINoteG8           = 115,
    MIDINoteGSharp8      = 116,
    MIDINoteA8           = 117,
    MIDINoteASharp8      = 118,
    MIDINoteB8           = 119,

    // Octave 9 (Highest standard MIDI notes)
    MIDINoteC9           = 120,
    MIDINoteCSharp9      = 121,
    MIDINoteD9           = 122,
    MIDINoteDSharp9      = 123,
    MIDINoteE9           = 124,
    MIDINoteF9           = 125,
    MIDINoteFSharp9      = 126,
    MIDINoteG9           = 127
};

typedef NS_ENUM(NSInteger, HATMusicalMode) {
    MusicalModeIonian,      // 0: Major Scale
    MusicalModeDorian,      // 1
    MusicalModePhrygian,    // 2
    MusicalModeLydian,      // 3
    MusicalModeMixolydian,  // 4
    MusicalModeAeolian,     // 5: Natural Minor Scale
    MusicalModeLocrian      // 6
};

NS_ASSUME_NONNULL_BEGIN

@interface HATNote : NSObject

/// Generates a scale of MIDI notes based on a root note and a specific mode.
/// @param rootNote The starting note (e.g., MIDINoteC4)
/// @param mode The musical mode (e.g., MusicalModeIonian for Major)
/// @param octaves How many octaves the scale should span (usually 1)
/// @return An array of NSNumber objects containing the MIDINote values.
+ (NSArray<NSNumber *> *)scaleFromRootNote:(HATMIDINote)rootNote
                                      mode:(HATMusicalMode)mode
                                   octaves:(NSUInteger)octaves;

@end

NS_ASSUME_NONNULL_END
