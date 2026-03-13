//
//  HATSoundFile.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HATSoundFontInstrument.h"

NS_ASSUME_NONNULL_BEGIN

@interface HATSoundFont : NSObject

+ (void)printInstrumentsInSoundFont:(NSURL*)fileURL;

@end

NS_ASSUME_NONNULL_END
