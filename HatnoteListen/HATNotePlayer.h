//
//  HATNotePlayer.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "HATNote.h"

NS_ASSUME_NONNULL_BEGIN

@interface HATNotePlayer : NSObject

- (void)playNote:(HATMIDINote)midiNote velocity:(uint8_t)velocity;
- (void)stopNote:(HATMIDINote)midiNote;

@end

NS_ASSUME_NONNULL_END
