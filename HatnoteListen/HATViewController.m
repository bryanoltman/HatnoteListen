//
//  HATViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATViewController.h"

@interface HATViewController ()
@property (strong, nonatomic) SRWebSocket *socket;
@end

@implementation HATViewController

+ (NSDictionary *)languageMap
{
    static NSDictionary *langs = nil;
    if (!langs) {
        langs = @{
                  @"en":  @"ws://wikimon.hatnote.com:9000",
                  @"de" : @"ws://wikimon.hatnote.com:9010",
                  @"ru":  @"ws://wikimon.hatnote.com:9020",
                  @"uk":  @"ws://wikimon.hatnote.com:9310",
                  @"ja": @"ws://wikimon.hatnote.com:9030",
                  @"es": @"ws://wikimon.hatnote.com:9040",
                  @"fr": @"ws://wikimon.hatnote.com:9050",
                  @"nl": @"ws://wikimon.hatnote.com:9060",
                  @"it":  @"ws://wikimon.hatnote.com:9070",
                  @"sv":  @"ws://wikimon.hatnote.com:9080",
                  @"ar": @"ws://wikimon.hatnote.com:9090",
                  @"fa": @"ws://wikimon.hatnote.com:9210",
                  @"he":  @"ws://wikimon.hatnote.com:9230",
                  @"id":  @"ws://wikimon.hatnote.com:9100",
                  @"zh":  @"ws://wikimon.hatnote.com:9240",
                  @"as": @"ws://wikimon.hatnote.com:9150",
                  @"hi": @"ws://wikimon.hatnote.com:9140",
                  @"bn":  @"ws://wikimon.hatnote.com:9160",
                  @"pa":  @"ws://wikimon.hatnote.com:9120",
                  @"te": @"ws://wikimon.hatnote.com:9160",
                  @"ta":  @"ws://wikimon.hatnote.com:9110",
                  @"ml":  @"ws://wikimon.hatnote.com:9250",
                  @"mr":  @"'ws://wikimon.hatnote.com:9130",
                  @"kn":  @"ws://wikimon.hatnote.com:9170",
                  @"or":  @"ws://wikimon.hatnote.com:9180",
                  @"sa":  @"ws://wikimon.hatnote.com:9190",
                  @"gu":  @"ws://wikimon.hatnote.com:9200",
                  @"pl":  @"ws://wikimon.hatnote.com:9260",
                  @"mk":  @"ws://wikimon.hatnote.com:9270",
                  @"be":  @"ws://wikimon.hatnote.com:9280",
                  @"bg":  @"ws://wikimon.hatnote.com:9300",
                  @"sr":  @"ws://wikimon.hatnote.com:9290",
                  @"wikidata": @"ws://wikimon.hatnote.com:9220"
              };
    }
    
    return langs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *langMap = [HATViewController languageMap];
    NSString *wsString = [langMap objectForKey:language] ?: @"en";
    
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:wsString]];
    self.socket.delegate = self;
    [self.socket open];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSDictionary *json = [message objectFromJSONString];
    NSLog(@"%@", json);
    // TODO
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    // TODO anything?
    NSLog(@"opened!");
}

@end
