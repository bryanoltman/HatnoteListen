//
//  HATNotePlayer.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import "HATNotePlayer.h"

#import "HATSoundFont.h"

@interface HATNotePlayer ()

@property(nonatomic, strong) AVAudioEngine* engine;
@property(nonatomic, strong) AVAudioUnitSampler* sampler;

@end

@implementation HATNotePlayer

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setupEngineAndLoadSoundFont];
  }
  return self;
}

- (void)setupEngineAndLoadSoundFont {
  self.engine = [[AVAudioEngine alloc] init];
  self.sampler = [[AVAudioUnitSampler alloc] init];

  // 1. Attach and connect the sampler to the engine
  [self.engine attachNode:self.sampler];
  [self.engine connect:self.sampler to:self.engine.mainMixerNode format:nil];

  // 2. Start the engine
  NSError* engineError = nil;
  if (![self.engine startAndReturnError:&engineError]) {
    NSLog(@"Failed to start engine: %@", engineError.localizedDescription);
    return;
  }

  // 3. Locate the SoundFont file in the App Bundle
  NSURL* soundFontURL = [[NSBundle mainBundle] URLForResource:@"Nokia_S30" withExtension:@"sf2"];
  [HATSoundFont printInstrumentsInSoundFont:soundFontURL];
  if (!soundFontURL) {
    NSLog(@"Error: Could not find sound font file.");
    return;
  }

  // 4. Load the SoundFont into the Sampler
  NSError* loadError = nil;

  // program: 0 selects the first instrument in the SoundFont.
  // Bank MSB/LSB constants specify standard melodic banks.
  BOOL success = [self.sampler loadSoundBankInstrumentAtURL:soundFontURL
                                                    program:24 // Acoustic Guitar
                                                    bankMSB:kAUSampler_DefaultMelodicBankMSB
                                                    bankLSB:kAUSampler_DefaultBankLSB
                                                      error:&loadError];

  if (!success) {
    NSLog(@"Failed to load SoundFont: %@", loadError.localizedDescription);
  }
}

- (void)playNote:(HATMIDINote)midiNote velocity:(uint8_t)velocity {
  // Channel 0 is standard for the first loaded instrument
  [self.sampler startNote:midiNote withVelocity:velocity onChannel:0];
  NSLog(@"Started note: %d", midiNote);
}

- (void)stopNote:(HATMIDINote)midiNote {
  [self.sampler stopNote:midiNote onChannel:0];
  NSLog(@"Stopped note: %d", midiNote);
}

@end
