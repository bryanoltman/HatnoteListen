//
//  HATViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define kNumClav 27
#define kNumCelesta 27
#define kNumSwells 3

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
                  @"de":  @"ws://wikimon.hatnote.com:9010",
                  @"ru":  @"ws://wikimon.hatnote.com:9020",
                  @"uk":  @"ws://wikimon.hatnote.com:9310",
                  @"ja":  @"ws://wikimon.hatnote.com:9030",
                  @"es":  @"ws://wikimon.hatnote.com:9040",
                  @"fr":  @"ws://wikimon.hatnote.com:9050",
                  @"nl":  @"ws://wikimon.hatnote.com:9060",
                  @"it":  @"ws://wikimon.hatnote.com:9070",
                  @"sv":  @"ws://wikimon.hatnote.com:9080",
                  @"ar":  @"ws://wikimon.hatnote.com:9090",
                  @"fa":  @"ws://wikimon.hatnote.com:9210",
                  @"he":  @"ws://wikimon.hatnote.com:9230",
                  @"id":  @"ws://wikimon.hatnote.com:9100",
                  @"zh":  @"ws://wikimon.hatnote.com:9240",
                  @"as":  @"ws://wikimon.hatnote.com:9150",
                  @"hi":  @"ws://wikimon.hatnote.com:9140",
                  @"bn":  @"ws://wikimon.hatnote.com:9160",
                  @"pa":  @"ws://wikimon.hatnote.com:9120",
                  @"te":  @"ws://wikimon.hatnote.com:9160",
                  @"ta":  @"ws://wikimon.hatnote.com:9110",
                  @"ml":  @"ws://wikimon.hatnote.com:9250",
                  @"mr":  @"ws://wikimon.hatnote.com:9130",
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

- (void)playSoundWithPath:(NSString *)path
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
    NSLog(@"attempting to open soundPath %@ from orig path %@", soundPath, path);
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSDictionary *json = [message objectFromJSONString];
//    NSLog(@"%@", json);
    
    NSString *soundPath;
    if ([[json objectForKey:@"page_title"] isEqualToString:@"Special:Log/newusers"]) {
        soundPath = [NSString stringWithFormat:@"swell%d", (rand() % kNumSwells) + 1];
        NSLog(@"%@", [json objectForKey:@"user"]);
    }
    else {
        NSNumber *changeSize = [json objectForKey:@"change_size"];
        if ([changeSize isKindOfClass:[NSNull class]]) {
            return;
        }
        
        //        so the clav is the bell sound, that's for additions
        //        and the celesta is the string sound, that's for subtractions
        BOOL isAddition = [changeSize intValue] > 0;
        if (isAddition) {
            soundPath = [NSString stringWithFormat:@"c%03d", (rand() % kNumClav) + 1];
        }
        else {
            soundPath = [NSString stringWithFormat:@"c%03d", (rand() % kNumCelesta) + 1];
        }
        
//        green is anon
//        purple is bot
//        white is registered
        NSNumber *isAnon = [json objectForKey:@"is_anon"];
        NSNumber *isBot = [json objectForKey:@"is_bot"];
        UIColor *dotColor;
        if ([isAnon boolValue]) {
            dotColor = [UIColor greenColor];
        }
        else if ([isBot boolValue]) {
            dotColor = [UIColor purpleColor];
        }
        else {
            dotColor = [UIColor whiteColor];
        }
        
        // TODO draw dot
        NSLog(@"%@", json);
    }
    
    NSLog(@"sound path is %@", soundPath);
    [self playSoundWithPath:soundPath];
}

//- (void)webSocketDidOpen:(SRWebSocket *)webSocket
//{
//    // TODO anything?
//    NSLog(@"opened!");
//}

@end
