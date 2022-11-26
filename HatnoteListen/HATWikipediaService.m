//
//  HATWikipediaService.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/24/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import "HATWikipediaService.h"
#import "NSArray+FunctionalHelper.h"

@interface HATWikipediaService () <NSURLSessionWebSocketDelegate>
@property (strong, nonatomic) NSMutableDictionary *languageCodesToTasks;
@end

@implementation HATWikipediaService

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    self.languageCodesToTasks = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)openSocketForLanguage:(HATWikipediaLanguage *)language
{
#ifdef DEBUG
  NSLog(@"opening socket for %@", language.name);
#endif

  NSURLSessionWebSocketTask *task = self.languageCodesToTasks[language.code];
  if (task && task.state == NSURLSessionTaskStateRunning)
  {
    // A socket is already open, don't need to open a new one.
    return;
  }

  NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:language.websocketURL];
  task = [[NSURLSession sharedSession] webSocketTaskWithRequest:urlRequest];
  task.delegate = self;
  [self receiveMessageForWebSocketTask:task language:language];
  [task resume];
  [self.languageCodesToTasks setObject:task forKey:language.code];
  return;
}

- (void)receiveMessageForWebSocketTask:(NSURLSessionWebSocketTask *)task language:(HATWikipediaLanguage *)language
{
  __weak HATWikipediaService *weakSelf = self;
  [task receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage *_Nullable message, NSError *_Nullable error) {
    if (error)
    {
      // TODO do something with error
#ifdef DEBUG
      NSLog(@"Error opening socket for %@", language.websocketURL);
#endif

      return;
    }

    dispatch_async(dispatch_get_main_queue(), ^(void) {
      [weakSelf.delegate wikipediaServiceDidReceiveMessage:message.string];
    });

    [weakSelf receiveMessageForWebSocketTask:task language:language];
  }];
}

- (void)closeSocketForLanguage:(HATWikipediaLanguage *)language
{
  NSURLSessionWebSocketTask *task = self.languageCodesToTasks[language.code];
  [task cancel];
  [self.languageCodesToTasks removeObjectForKey:language.code];
}

- (void)closeAllSockets
{
  for (NSString *languageCode in self.languageCodesToTasks)
  {
    [self.languageCodesToTasks[languageCode] cancel];
  }

  [self.languageCodesToTasks removeAllObjects];
}

#pragma mark - NSURLSessionWebSocketDelegate
- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didOpenWithProtocol:(NSString *)protocol
{
#ifdef DEBUG
  NSLog(@"Opened socket task %@ with protocol %@", webSocketTask, protocol);
#endif
}

- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode reason:(NSData *)reason
{
#ifdef DEBUG
  NSLog(@"Closed socket task %@ with reason: %@", webSocketTask, [[NSString alloc] initWithData:reason encoding:NSUTF8StringEncoding]);
#endif
}

@end
