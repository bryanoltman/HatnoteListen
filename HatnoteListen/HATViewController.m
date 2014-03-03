//
//  HATViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATViewController.h"
#import "HATUpdateView.h"
#import "HATWikipediaViewController.h"

#define kNumClav 27
#define kNumCelesta 27
#define kNumSwells 3
#define kNewUserTargetColor 0x2980b9

@interface HATViewController ()
@property (strong, nonatomic) SRWebSocket *socket;
@property (strong, nonatomic) HATWikipediaViewController *wikiVC;
@property (strong, nonatomic) NSMutableArray *avPlayers;
@property (strong, nonatomic) NSMutableArray *dotViews;
@property (strong, nonatomic) NSTimer *wikiHideTimer;
@property (strong, nonatomic) NSTimer *userHideTimer;
@end

@implementation HATViewController

+ (NSDictionary *)languageUrlMap
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

+ (NSDictionary *)languageNameMap
{
    NSDictionary *langs = nil;
    if (!langs) {
        langs = @{
                  @"en": @"English",
                  @"de": @"German",
                  @"ru": @"Russian",
                  @"uk": @"Ukrainian",
                  @"ja": @"Japanese",
                  @"es": @"Spanish",
                  @"fr": @"French",
                  @"nl": @"Dutch",
                  @"it": @"Italian",
                  @"sv": @"Swedish",
                  @"ar": @"Arabic",
                  @"fa": @"Farsi",
                  @"he": @"Hebrew",
                  @"id": @"Indonesian",
                  @"zh": @"Chinese",
                  @"as": @"Assamese",
                  @"hi": @"Hindi",
                  @"bn": @"Bengali",
                  @"pa": @"Punjabi",
                  @"te": @"Telugu",
                  @"ta": @"Tamil",
                  @"ml": @"Malayalam",
                  @"mr": @"Western Mari",
                  @"kn": @"Kannada",
                  @"or": @"Oriya",
                  @"sa": @"Sanskrit", 
                  @"gu": @"Gujarati",
                  @"pl": @"Polish" ,
                  @"mk": @"Macedonian",
                  @"be": @"Belarusian",
                  @"bg": @"Bulgarian",
                  @"sr": @"Serbian"
                  };
    }
    
    return langs;
}

+ (NSArray *)newUserMessages
{
    static NSArray *ret = nil;
    if (!ret) {
        ret = @[@"Welcome to %@, Wikipedia's newest user!",
                @"Wikipedia has a new user, %@! Welcome!",
                @"%@ has joined Wikipedia!"];
    }
    
    return ret;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.avPlayers = [NSMutableArray array];
        self.dotViews = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bubbleClicked:)
                                                     name:@"bubbleClicked"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didBecomeActive)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didEnterBackground)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"bubbleClicked"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.wikiVC = self.childViewControllers[0];
    [self hideNewUserView:NO];
    [self hideWikiView:NO];
    
    [self initSocket];
}

- (void)setMuteButton:(UIButton *)muteButton
{
    _muteButton = muteButton;
    UIImage *image = [UIImage imageNamed:@"speaker-down"];
    [muteButton setImage:image forState:(UIControlStateHighlighted | UIControlStateSelected)];
}

- (void)initSocket
{
    if (self.socket) {
        return;
    }
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *langMap = [HATViewController languageUrlMap];
    NSString *wsString = [langMap objectForKey:language] ?: @"en";
    
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:wsString]];
    self.socket.delegate = self;
    [self.socket open];
}

- (void)didEnterBackground
{
    [self.socket close];
    self.socket = nil;
}

- (void)didBecomeActive
{
    [self initSocket];
}

- (void)bubbleClicked:(NSNotification *)notification
{
    NSDictionary *info = notification.object;
    self.wikiVC.info = info;
    [self showWikiView:YES];
}

- (void)showNewUserView:(BOOL)animated
{
    self.userView.alpha = 1;
    [UIView animateWithDuration:animated ? 0.3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.userView.transform = CGAffineTransformIdentity;
                     } completion:nil];
    
    [self.userHideTimer invalidate];
    self.userHideTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:self
                                                        selector:@selector(removeTimerTicked:)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)hideNewUserView:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.userView.alpha = 0;
                     } completion:^(BOOL finished) {
                         self.userView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.userView.bounds));
                     }];
}

- (void)showWikiView:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.wikiVC.view.transform = CGAffineTransformIdentity;
                         self.muteButton.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.wikiVC.view.frame));
                     } completion:nil];
    
    [self.wikiHideTimer invalidate];
    self.wikiHideTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(removeTimerTicked:)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)removeTimerTicked:(NSTimer *)timer
{
    if (timer == self.userHideTimer) {
        [self hideNewUserView:YES];
    }
    else if (timer == self.wikiHideTimer) {
        [self hideWikiView:YES];
    }
}

- (void)hideWikiView:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.3 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.wikiVC.view.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.wikiVC.view.frame));
                         self.muteButton.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

- (void)playSoundWithPath:(NSString *)path
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:soundPath];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.volume = self.muteButton.selected ? 0 : 1;
    player.delegate = self;
    [self.avPlayers addObject:player];
    [player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.avPlayers removeObject:player];
}

- (CGPoint)getRandomPoint
{
    return CGPointMake(fmod(arc4random(), CGRectGetWidth(self.view.bounds)),
                       fmod(arc4random(), CGRectGetHeight(self.view.bounds)));
}

- (void)showViewCenteredAt:(CGPoint)point
                 withColor:(UIColor *)color
                 magnitude:(NSInteger)magnitude
                  andInfo:(NSDictionary *)info
{
    CGFloat magMultiple = 0.5;
    CGFloat radius = MAX(0, MIN(magMultiple * magnitude, CGRectGetHeight(self.view.bounds)));
    
    HATUpdateView *dotView = [[HATUpdateView alloc] initWithFrame:CGRectMake(point.x - radius / 2,
                                                                             point.y - radius / 2,
                                                                             radius,
                                                                             radius)];
    dotView.color = color;
    dotView.magnitude = magnitude;
    dotView.info = info;
    dotView.alpha = 0.6;
    [self.view insertSubview:dotView atIndex:0];
    [self.dotViews addObject:dotView];
    dotView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.8 + (fmodf(arc4random(), 100) / 100) // 0.8 + 0 to 1 seconds
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         dotView.transform = CGAffineTransformMakeScale(1, 1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:6
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseIn
                                          animations:^{
//                                                       [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                                           dotView.transform = CGAffineTransformTranslate(dotView.transform, 0, -1.0f * fmodf(arc4random(), 100));
//                                                       }];
//
//                                                       [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.4 animations:^{
//                                                           dotView.transform = CGAffineTransformScale(dotView.transform, 0.7, 0.7);
//                                                       }];
//                                                       
//                                                       [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
//                                                           dotView.transform = CGAffineTransformScale(dotView.transform, 0.0, 0.0);
//                                                       }];
//
//                                                       [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
//                                                           dotView.alpha = 0.3;
//                                                       }];
                                                   } completion:^(BOOL finished) {
                                                       [UIView animateWithDuration:0.2
                                                                        animations:^{
                                                                            dotView.alpha = 0;
                                                                            dotView.transform = CGAffineTransformScale(dotView.transform,
                                                                                                                       0.1, 0.1);
                                                                        } completion:^(BOOL finished) {
                                                                            [dotView removeFromSuperview];
                                                                            [self.dotViews removeObject:dotView];
                                                                        }];
                                                   }];
                     }];

}

- (void)muteButtonClicked:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    for (AVAudioPlayer *player in self.avPlayers) {
        player.volume = self.muteButton.selected ? 0 : 1;
    }
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSDictionary *json = [message objectFromJSONString];
    NSString *soundPath;
    if ([json[@"page_title"] isEqualToString:@"Special:Log/newusers"]) {
        soundPath = [NSString stringWithFormat:@"swell%d", (rand() % kNumSwells) + 1];
        NSString *message = [[HATViewController newUserMessages] randomObject];
        self.userLabel.text = [NSString stringWithFormat:message, json[@"user"]];
        [self showNewUserView:YES];
    }
    else if (![[json[@"ns"] lowercaseString] isEqualToString:@"main"]) {
        return;
    }
    else {
        NSNumber *changeSize = json[@"change_size"];
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
        NSNumber *isAnon = json[@"is_anon"];
        NSNumber *isBot = json[@"is_bot"];
        UIColor *dotColor;
        if ([isAnon boolValue]) {
            dotColor = [UIColor colorWithRed:46.0/255.0
                                       green:204.0/255.0
                                        blue:113.0/255.0
                                       alpha:1];
        }
        else if ([isBot boolValue]) {
            dotColor = [UIColor colorWithRed:155.0/255.0
                                       green:89.0/255.0
                                        blue:182.0/255.0
                                       alpha:1];
        }
        else {
            dotColor = [UIColor whiteColor];
        }
        
        [self showViewCenteredAt:[self getRandomPoint]
                       withColor:dotColor
                       magnitude:changeSize.integerValue
                         andInfo:json];
    }
    
    [self playSoundWithPath:soundPath];
}

@end
