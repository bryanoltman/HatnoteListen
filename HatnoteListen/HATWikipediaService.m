//
//  HATWikipediaService.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/24/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import "HATWikipediaService.h"
#import "NSArray+FunctionalHelper.h"

@interface HATWikipediaService () <SRWebSocketDelegate>
@end

@implementation HATWikipediaService

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    self.sockets = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)openSocketForLanguage:(HATWikipediaLanguage *)language
{
#ifdef DEBUG
  NSLog(@"opening socket for %@", language.name);
#endif

  SRWebSocket *socket = self.sockets[language.code];
  if (socket && (socket.readyState == SR_OPEN || socket.readyState == SR_CONNECTING))
  {
    // A socket is already open, don't need to open a new one.
    return;
  }

  socket = [[SRWebSocket alloc] initWithURL:language.websocketURL];
  socket.delegate = self;
  [socket open];
  [self.sockets setObject:socket forKey:language.code];
  return;
}

- (void)closeSocketForLanguage:(HATWikipediaLanguage *)language
{
  SRWebSocket *socket = self.sockets[language.code];
  [socket close];
  [self.sockets removeObjectForKey:language.code];
}

- (void)closeAllSockets
{
  [self.sockets enumerateKeysAndObjectsUsingBlock:^(id key, SRWebSocket *socket, BOOL *stop) {
    [socket close];
  }];

  [self.sockets removeAllObjects];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
  [self.delegate wikipediaServiceDidReceiveMessage:message];
}

@end
