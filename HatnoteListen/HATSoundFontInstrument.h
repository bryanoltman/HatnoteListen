//
//  HATSoundFontInstrument.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/12/26.
//  Copyright © 2026 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HATSoundFontInstrument : NSObject

@property(strong, nonatomic) NSString* name;
@property(nonatomic) int bank;
@property(nonatomic) int program;

- (HATSoundFontInstrument*)initWithName:(NSString*)name bank:(int)bank program:(int)program;

@end

NS_ASSUME_NONNULL_END
