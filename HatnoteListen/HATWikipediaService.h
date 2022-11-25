//
//  HATWikipediaService.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/24/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HATWikipediaServiceDelegate <NSObject>

- (void)wikipediaServiceDidReceiveMessage:(NSString *)message;

@end

@interface HATWikipediaService : NSObject

@property (strong, nonatomic) NSMutableDictionary *sockets;
@property (weak, nonatomic) id<HATWikipediaServiceDelegate> delegate;

- (void)openSocketForLanguage:(HATWikipediaLanguage *)language;
- (void)closeSocketForLanguage:(HATWikipediaLanguage *)language;
- (void)closeAllSockets;

@end

NS_ASSUME_NONNULL_END
