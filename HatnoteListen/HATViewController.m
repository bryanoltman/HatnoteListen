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
#import "HATSettingsViewController.h"

#define kNumClav 27
#define kNumCelesta 27
#define kNumSwells 3

@interface HATViewController ()
@property (strong, nonatomic) FBKVOController *KVOController;
@property (strong, nonatomic) NSMutableDictionary *sockets;
@property (strong, nonatomic) HATWikipediaViewController *wikiVC;
@property (strong, nonatomic) HATSettingsViewController *settingsVC;
@property (strong, nonatomic) NSMutableArray *avPlayers;
@property (strong, nonatomic) NSTimer *wikiHideTimer;
@property (strong, nonatomic) NSTimer *userHideTimer;
@property (strong, nonatomic) NSString *newestUserName;
@property (strong, nonatomic) NSDate *startTime;
@end

@implementation HATViewController

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
        self.startTime = [NSDate date];
        self.avPlayers = [NSMutableArray new];
        self.sockets = [NSMutableDictionary new];
        self.KVOController = [FBKVOController controllerWithObserver:self];

        __weak HATViewController *weakSelf = self;
        [self.KVOController observe:[HATSettings sharedSettings]
                            keyPath:@"selectedLanguages"
                            options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                              block:^(id observer, HATSettings *settings, NSDictionary *change) {
                                  NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] integerValue];
                                  if (kind & (NSKeyValueChangeInsertion|NSKeyValueChangeSetting)) {
                                      [change[NSKeyValueChangeNewKey] each:^(HATWikipediaLanguage *lang) {
                                          [weakSelf openSocketForLanguage:lang];
                                      }];
                                  }
                                  else if (kind & NSKeyValueChangeRemoval) {
                                      [change[NSKeyValueChangeOldKey] each:^(HATWikipediaLanguage *lang) {
                                          [weakSelf closeSocketForLanguage:lang];
                                      }];
                                  }
                              }];
        
        [self.KVOController observe:[appDelegate container]
                            keyPath:@"state"
                            options:(NSKeyValueObservingOptionNew|NSKeyValueChangeSetting)
                              block:^(id observer, id object, NSDictionary *change) {
                                  if ([change[NSKeyValueChangeNewKey] isEqual:@(JASidePanelLeftVisible)]) {
                                      [weakSelf hideAboutView];
                                      [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                                              withAnimation:UIStatusBarAnimationFade];
                                  }
                                  else {
                                      [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                                              withAnimation:UIStatusBarAnimationFade];
                                  }
         }];
        
        [self.KVOController observe:[HATSettings sharedSettings]
                            keyPath:@"soundsMuted"
                            options:NSKeyValueObservingOptionNew
                              block:^(id observer, id object, NSDictionary *change) {
                                  BOOL muted = [change[NSKeyValueChangeNewKey] boolValue];
                                  for (AVAudioPlayer *player in self.avPlayers) {
                                      player.volume = muted ? 0 : 1;
                                  }
                                  
                                  [self.muteButton setSelected:muted];
                              }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bubbleClicked:)
                                                     name:@"bubbleClicked"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
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
 
    self.view.backgroundColor = [UIColor backgroundColor];
    
    self.muteButton.alpha = 0;
    self.muteButton.selected = [[HATSettings sharedSettings] soundsMuted];
    
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:self.userView.frame];
    bar.autoresizingMask = self.userView.autoresizingMask;
    bar.barTintColor = [UIColor bannerTintColor];
    [self.userView removeFromSuperview];
    self.userView = bar;
    [self.userView addSubview:self.userLabel];
    [self.view addSubview:self.userView];
    
    self.wikiVC = [self.childViewControllers find:^BOOL(id vc) {
        return [vc isKindOfClass:[HATWikipediaViewController class]];
    }];
    
    self.settingsVC = [self.childViewControllers find:^BOOL(id vc) {
        return [vc isKindOfClass:[HATSettingsViewController class]];
    }];
    
    self.settingsVC.view.hidden = YES;
    
    [self hideNewUserView:NO];
    [self hideWikiView:NO];
    
    BOOL hasUserSeenWelcome = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownWelcome"];
    if (!hasUserSeenWelcome) {
        [self performBlock:^{
            [self showAboutView:HATAboutScreenContentWelcome];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shownWelcome"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } afterDelay:0.2];
    }
}

- (void)didReceiveMemoryWarning
{
    [self.avPlayers removeAllObjects];
    
    for (UIView *subview in self.view.subviews) {
        if (![subview isKindOfClass:[HATUpdateView class]]) {
            break;
        }
        
        HATUpdateView *dotView = (HATUpdateView *)subview;
        [UIView animateWithDuration:0.4
                         animations:^{
                             dotView.alpha = 0;
                             dotView.transform = CGAffineTransformScale(dotView.transform,
                                                                        0.1, 0.1);
                         } completion:^(BOOL finished) {
                             [dotView removeFromSuperview];
                         }];
    }
}

- (NSString *)currentLanguageCode
{
    return [[NSLocale preferredLanguages] objectAtIndex:0] ?: @"en";
}

- (void)setMuteButton:(UIButton *)muteButton
{
    _muteButton = muteButton;
    UIImage *image = [UIImage imageNamed:@"speaker-down"];
    [muteButton setImage:image forState:(UIControlStateHighlighted | UIControlStateSelected)];
}

#pragma mark - Socket
- (void)openSocketForLanguage:(HATWikipediaLanguage *)language
{
    NSLog(@"opening socket for %@", language.name);
    SRWebSocket *socket = self.sockets[language.code];
    if (socket && (socket.readyState == SR_OPEN || socket.readyState == SR_CONNECTING)) {
        return;
    }
    
    socket = [[SRWebSocket alloc] initWithURL:language.websocketURL];
    socket.delegate = self;
    [socket open];
    [self.sockets setObject:socket forKey:language.code];
}

- (void)closeSocketForLanguage:(HATWikipediaLanguage *)language
{
    SRWebSocket *socket = self.sockets[language.code];
    [socket close];
    [self.sockets removeObjectForKey:language.code];
}

- (void)didEnterBackground
{
    [self.sockets enumerateKeysAndObjectsUsingBlock:^(id key, SRWebSocket *socket, BOOL *stop) {
        [socket close];
    }];
    
    [self.sockets removeAllObjects];
}

- (void)didBecomeActive
{
    self.startTime = [NSDate date];
    
    [[[HATSettings sharedSettings] selectedLanguages] each:^(HATWikipediaLanguage *lang) {
        [self openSocketForLanguage:lang];
    }];
}

#pragma mark - Events
- (void)bubbleClicked:(NSNotification *)notification
{
    NSDictionary *info = notification.object;
    self.wikiVC.info = info;
    [self showWikiView:YES];
}

- (void)muteButtonClicked:(UIButton *)sender
{
    [[HATSettings sharedSettings] setSoundsMuted:!self.muteButton.selected];
}

- (void)newUserViewTapped:(UITapGestureRecognizer *)recognizer
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@.wikipedia.org/w/index.php?title=User_talk:%@&action=edit&section=new",
                           self.currentLanguageCode, self.newestUserName];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)backgroundTapped:(id)sender
{
    static NSTimer *timer = nil;
    if (timer) {
        [timer invalidate];
    }

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.muteButton.alpha = 1.f;
                     }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2
                                             target:self
                                           selector:@selector(muteButtonTimerTicked:)
                                           userInfo:nil
                                            repeats:NO];
}

- (void)muteButtonTimerTicked:(NSTimer *)timer
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.muteButton.alpha = 0;
                     }];
}

#pragma mark - Auxiliary Views
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
    self.wikiHideTimer = [NSTimer scheduledTimerWithTimeInterval:9
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

- (void)showAboutView:(HATAboutScreenContent)content
{
    [[appDelegate container] showCenterPanelAnimated:YES];
    self.aboutVC = [[UIStoryboard storyboardWithName:@"About"
                                              bundle:nil]
                    instantiateInitialViewController];
    self.aboutVC.view.frame = [appDelegate container].centerPanelContainer.frame;
    
    [[appDelegate container] addChildViewController:self.aboutVC];
    [[appDelegate container].view addSubview:self.aboutVC.view];
    
    [self.aboutVC show:content];
}

- (void)hideAboutView
{
    [self.aboutVC hide:^{
        [self.aboutVC removeFromParentViewController];
        [self.aboutVC.view removeFromSuperview];
        self.aboutVC = nil;
    }];
}

#pragma mark - Dot Display
- (CGPoint)getRandomPoint
{
    CGPoint ret = CGPointMake(fmod(arc4random(), CGRectGetWidth(self.view.bounds) - 30),
                              fmod(arc4random(), CGRectGetHeight(self.view.bounds) - 30));
    return ret;
}

- (void)showViewCenteredAt:(CGPoint)point
             withMagnitude:(NSInteger)magnitude
                    andInfo:(NSDictionary *)info
{
    CGFloat magMultiple = 0.5;
    CGFloat radius = CLAMP(0, magMultiple * magnitude, CGRectGetHeight(self.view.bounds));

    HATUpdateView *dotView = [[HATUpdateView alloc] initWithFrame:CGRectMake(point.x - radius / 2,
                                                                             point.y - radius / 2,
                                                                             radius,
                                                                             radius)
                                                          andInfo:info];
    [self.view insertSubview:dotView atIndex:0];
    dotView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    CGFloat adjustment = MIN(MAX(0, radius / 100), 0.3);
    [UIView animateWithDuration:0.3 + (fmodf(arc4random(), 50) / 100) // 0.6 + 0 to 0.5 seconds
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:0.95 - adjustment
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         dotView.transform = CGAffineTransformMakeScale(1, 1);
                     } completion:^(BOOL finished) {
                         CGFloat floatDuration = 12;
                         CGFloat fadeDuration = 7;
                         [UIView animateWithDuration:fadeDuration
                                               delay:floatDuration - fadeDuration
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              dotView.alpha = 0;
                                          } completion:nil];
                         
                         [UIView animateWithDuration:floatDuration
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              dotView.showTime = [NSDate date];
                                              dotView.duration = floatDuration;
                                              CGFloat scale = .88;
                                              CGAffineTransform trans = CGAffineTransformMakeScale(scale, scale);;
                                              trans = CGAffineTransformTranslate(trans, 0, -100 - 1.0f * fmodf(arc4random(), 200));
                                              dotView.transform = trans;
                                          } completion:^(BOOL finished) {
                                              [dotView removeFromSuperview];
                                          }];
                     }];
}

#pragma mark - Audio
- (void)playSoundWithPath:(NSString *)path
{
    if ([[HATSettings sharedSettings] soundsMuted]) {
        return;
    }
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
    if (!soundPath) {
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:soundPath];
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.volume = [[HATSettings sharedSettings] soundsMuted] ? 0 : 1;
    player.delegate = self;
    [self.avPlayers addObject:player];
    [player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.avPlayers removeObject:player];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSDictionary *json = [message objectFromJSONString];
    NSString *soundPath;
    if ([json[@"page_title"] isEqualToString:@"Special:Log/newusers"]) {
        // Don't show new user notifications during the first 20 seconds
        if ([[NSDate date] timeIntervalSinceDate:self.startTime] < 20) {
            return;
        }
        
        soundPath = [NSString stringWithFormat:@"swell%d", (rand() % kNumSwells) + 1];
        NSString *message = [[HATViewController newUserMessages] randomObject];
        self.newestUserName = json[@"user"];
        self.userLabel.text = [NSString stringWithFormat:message, self.newestUserName];
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
        
        int index = CLAMP(1, (fabsf(changeSize.floatValue) / 500.f) * kNumCelesta, kNumCelesta);
        index = kNumCelesta - index + 1;

//        so the clav is the bell sound, that's for additions
//        and the celesta is the string sound, that's for subtractions
        BOOL isAddition = [changeSize intValue] > 0;
        if (isAddition) {
            soundPath = [NSString stringWithFormat:@"clav%03d", index];
        }
        else {
            soundPath = [NSString stringWithFormat:@"cel%03d", index];
        }
        
        CGFloat dotMin = arc4random() % 100 + 35;
        [self showViewCenteredAt:[self getRandomPoint]
                   withMagnitude:MAX(labs(changeSize.integerValue), dotMin)
                         andInfo:json];
    }
    
    [self playSoundWithPath:soundPath];
}

@end
