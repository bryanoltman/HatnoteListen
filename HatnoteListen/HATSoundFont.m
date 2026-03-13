//
//  HATSoundFont.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import "HATSoundFont.h"

// 1. Define the standard SoundFont 2.01 Preset Header
// We use #pragma pack to ensure the compiler doesn't add padding bytes,
// keeping the struct exactly 38 bytes to match the binary file specification.
#pragma pack(push, 1)
typedef struct {
  char presetName[20];
  uint16_t preset;  // The MIDI Program number
  uint16_t bank;    // The MIDI Bank number
  uint16_t presetBagNdx;
  uint32_t library;
  uint32_t genre;
  uint32_t morphology;
} SFPresetHeader;
#pragma pack(pop)

@implementation HATSoundFont

+ (void)printInstrumentsInSoundFont:(NSURL*)fileURL {
  NSError* error = nil;

  // Use memory mapping so we don't load a massive gigabyte-sized SF2 entirely into RAM
  NSData* data = [NSData dataWithContentsOfURL:fileURL
                                       options:NSDataReadingMappedIfSafe
                                         error:&error];

  if (!data) {
    NSLog(@"Failed to load file: %@", error.localizedDescription);
    return;
  }

  // 2. Scan the binary data for the 'phdr' (Preset Header) chunk marker
  const char phdrMarker[] = {'p', 'h', 'd', 'r'};
  NSData* markerData = [NSData dataWithBytes:phdrMarker length:4];
  NSRange markerRange = [data rangeOfData:markerData options:0 range:NSMakeRange(0, data.length)];

  if (markerRange.location == NSNotFound) {
    NSLog(@"Could not find 'phdr' chunk. This might not be a valid SF2 file.");
    return;
  }

  // 3. The 4 bytes immediately following the marker tell us the size of the chunk
  uint32_t chunkSize = 0;
  [data getBytes:&chunkSize range:NSMakeRange(markerRange.location + 4, 4)];

  // 4. Calculate how many presets exist by dividing the chunk size by our 38-byte struct
  NSUInteger presetCount = chunkSize / sizeof(SFPresetHeader);
  NSUInteger startOffset = markerRange.location + 8;  // 4 bytes for 'phdr' + 4 bytes for size

  NSLog(@"\n--- SoundFont Instruments ---");

  NSMutableArray<HATSoundFontInstrument*>* instruments = [[NSMutableArray alloc] init];

  // 5. Loop through the binary chunk and extract each instrument
  for (NSUInteger i = 0; i < presetCount; i++) {
    SFPresetHeader header;
    [data getBytes:&header
             range:NSMakeRange(startOffset + (i * sizeof(SFPresetHeader)), sizeof(SFPresetHeader))];

    // Ensure the string is null-terminated for safe printing
    char safeName[21] = {0};
    strncpy(safeName, header.presetName, 20);

    // The last record in every SF2 file is universally "EOP" (End Of Presets). We can skip it.
    if (strcmp(safeName, "EOP") == 0) {
      continue;
    }

    // Print the result. The 'preset' is a number given to an instrument in a sound font.
    HATSoundFontInstrument* instrument =
        [[HATSoundFontInstrument alloc] initWithName:[NSString stringWithFormat:@"%s", safeName]
                                                bank:header.bank
                                             program:header.preset];

        [instruments addObject:instrument];
    NSLog(@"%@", instrument);
  }

  NSLog(@"-----------------------------\n");
}

@end
