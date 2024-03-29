//
//  HATViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "HATArticleTitleView.h"
#import "HATControlOverlayView.h"
#import "HATSettingsViewController.h"
#import "HATUpdateView.h"
#import "HATUserJoinedBanner.h"
#import "HATViewController.h"
#import "HATWikipediaService.h"

#define kNumClav 24
#define kNumCelesta 24
#define kNumSwells 3
#define kMaxSimultaneousSounds 15

int indexForChangeSize(double changeSize)
{
  // listen.hatnote.com logic:
  //  var max_pitch = 100.0;
  //  var log_used = 1.0715307808111486871978099;
  //  var pitch = 100 - Math.min(max_pitch, Math.log(size + log_used) / Math.log(log_used));
  //  var index = Math.floor(pitch / 100.0 * Object.keys(celesta).length);
  //  var fuzz = Math.floor(Math.random() * 4) - 2;
  //  index += fuzz;
  //  index = Math.min(Object.keys(celesta).length - 1, index);
  //  index = Math.max(1, index);
  //  if (current_notes < note_overlap) {
  //      current_notes++;
  //      if (type == 'add') {
  //          celesta[index].play();
  //      } else {
  //          clav[index].play();
  //      }
  //      setTimeout(function() {
  //          current_notes--;
  //      }, note_timeout);
  //  }
  //
  static CGFloat maxPitch = 100.0;
  static CGFloat logBase = 1.0715307808111486871978099;
  CGFloat pitch = maxPitch - MIN(maxPitch, log(fabs(changeSize) + logBase) / log(logBase));
  int index = CLAMP(1, floor(pitch / 100 * kNumCelesta), kNumCelesta);
  return index;
}

@interface HATViewController () <HATUserJoinedBannerDelegate, HATWikipediaServiceDelegate, HATArticleTitleViewDelegate>
@property (strong, nonatomic) FBKVOController *KVOController;
@property (strong, nonatomic) HATArticleTitleView *articleTitleView;
@property (strong, nonatomic) HATSettingsViewController *settingsVC;
@property (strong, nonatomic) NSMutableArray *avPlayers;
@property (strong, nonatomic) NSString *newestUserName;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) NSMutableDictionary *viewsToPoints;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) HATWikipediaService *wikipediaService;
@property (strong, nonatomic) HATUserJoinedBanner *userJoinedBanner;
@property (strong, nonatomic) HATControlOverlayView *controlOverlayView;
@property (strong, nonatomic) HATUpdateView *selectedView;
@property (nonatomic) BOOL isDisplayingNewUserBanner;
@end

@implementation HATViewController

- (CGFloat)adjustAngleForInterfaceOrientation:(CGFloat)angle
{
  switch (self.interfaceOrientation)
  {
    case UIInterfaceOrientationLandscapeLeft:
      angle += M_PI_2;
      break;
    case UIInterfaceOrientationLandscapeRight:
      angle += -M_PI_2;
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      angle += M_PI_2;
      break;
    default:
      break;
  }

  return angle;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self)
  {
    self.startTime = [NSDate date];
    self.avPlayers = [NSMutableArray new];
    self.viewsToPoints = [NSMutableDictionary new];
    self.motionManager = [CMMotionManager new];
    self.motionManager.deviceMotionUpdateInterval = 1.f / 60.f;
    self.wikipediaService = [[HATWikipediaService alloc] init];
    self.wikipediaService.delegate = self;

    CADisplayLink *displayLink =
        [CADisplayLink displayLinkWithTarget:self
                                    selector:@selector(displayLinkTriggered:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    __weak HATViewController *weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                              CGFloat angle =
                                                  atan2(motion.gravity.y, -motion.gravity.x);
                                              weakSelf.gravityBehavior.angle =
                                                  [self adjustAngleForInterfaceOrientation:angle];
                                            }];

    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController
        observe:[HATSettings sharedSettings]
        keyPath:@"selectedLanguages"
        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew |
                NSKeyValueObservingOptionOld
          block:^(id observer, HATSettings *settings, NSDictionary *change) {
            NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] integerValue];
            if (kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeSetting)
            {
              for (HATWikipediaLanguage *lang in change[NSKeyValueChangeNewKey])
              {
                [weakSelf.wikipediaService openSocketForLanguage:lang];
              }
            }
            else if (kind == NSKeyValueChangeRemoval)
            {
              [change[NSKeyValueChangeOldKey] each:^(HATWikipediaLanguage *lang) {
                [weakSelf.wikipediaService closeSocketForLanguage:lang];
              }];
            }
          }];

    [self.KVOController
        observe:[appDelegate sidePanelController]
        keyPath:@"state"
        options:(NSKeyValueObservingOptionNew | NSKeyValueChangeSetting)
          block:^(id observer, id object, NSDictionary *change) {
            if ([change[NSKeyValueChangeNewKey] isEqual:@(JASidePanelLeftVisible)])
            {
              [weakSelf hideAboutView];
              [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                      withAnimation:UIStatusBarAnimationFade];
            }
            else
            {
              [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                      withAnimation:UIStatusBarAnimationFade];
            }
          }];

    [self.KVOController observe:[HATSettings sharedSettings]
                        keyPath:@"soundsMuted"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                            BOOL muted = [change[NSKeyValueChangeNewKey] boolValue];
                            for (AVAudioPlayer *player in self.avPlayers)
                            {
                              player.volume = muted ? 0 : 1;
                            }
                          }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bubbleClicked:)
                                                 name:@"bubbleClicked"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundClicked:)
                                                 name:@"backgroundClicked"
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

- (void)displayLinkTriggered:(CADisplayLink *)link
{
  return;
  for (HATUpdateView *view in self.view.subviews)
  {
    if (![view isKindOfClass:[HATUpdateView class]])
    {
      continue;
    }

    if (view == _selectedView)
    {
      view.textAngle =
          [self adjustAngleForInterfaceOrientation:self.gravityBehavior.angle + M_PI_2];
      continue;
    }

    if (![view showsText])
    {
      continue;
    }

    CGPoint currentPoint = ((CALayer *)view.layer.presentationLayer).frame.origin;
    NSMutableArray *points = self.viewsToPoints[view.info[@"page_title"]];
    if (points)
    {
      CGPoint lastPoint = [[points firstObject] CGPointValue];
      CGVector direction = CGVectorMake(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y);
      if (CGVectorLength(direction) > 2.5)
      {
        [points removeObjectAtIndex:0];
        CGFloat textAngle = atan2(direction.dy, direction.dx) + M_PI_2;
        textAngle = [self adjustAngleForInterfaceOrientation:textAngle];
        view.textAngle = textAngle;
      }
    }
    else if (!points)
    {
      points = [NSMutableArray new];
      [self.viewsToPoints setObject:points forKey:view.info[@"page_title"]];
      view.textAngle = self.gravityBehavior.angle + M_PI_2;
    }

    [points addObject:[NSValue valueWithCGPoint:currentPoint]];
  }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bubbleClicked" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"backgroundClicked" object:nil];
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

- (void)setSelectedView:(HATUpdateView *)selectedView
{
  HATUpdateView *previousView = _selectedView;
  _selectedView = selectedView;
  selectedView.textAngle = 0;
  if (_selectedView)
  {
    NSString *urlString = _selectedView.info[@"url"];
    // Convert the article URL to a mobile URL.
    urlString = [urlString stringByReplacingOccurrencesOfString:@".wikipedia.org/"
                                                     withString:@".m.wikipedia.org/"];
    [self.articleTitleView setText:_selectedView.info[@"page_title"]
                               url:[NSURL URLWithString:urlString]];
    [self showArticleTitleView:YES];
  }
  else
  {
    [self hideArticleTitleView:YES];
  }

  [self animateSelectionChangeFromView:previousView toView:selectedView];
}

- (void)updateControlOverlayConstraints
{
  [self.controlOverlayView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (self.isDisplayingNewUserBanner)
    {
      make.top.equalTo(self.userJoinedBanner.mas_bottom).inset(12);
    }
    else
    {
      make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(8);
    }
    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).inset(12);
  }];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor backgroundColor];

  self.userJoinedBanner = [[HATUserJoinedBanner alloc] init];
  self.userJoinedBanner.delegate = self;
  [self.view addSubview:self.userJoinedBanner];
  [self.userJoinedBanner mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.top.trailing.equalTo(self.view);
  }];

  self.articleTitleView = [[HATArticleTitleView alloc] init];
  self.articleTitleView.delegate = self;
  [self.view addSubview:self.articleTitleView];
  [self.articleTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.leading.bottom.trailing.equalTo(self.view);
  }];

  self.controlOverlayView = [[HATControlOverlayView alloc] init];
  [self.view addSubview:self.controlOverlayView];
  [self updateControlOverlayConstraints];

  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

  self.gravityBehavior = [UIGravityBehavior new];
  self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
  self.gravityBehavior.magnitude = 0.01;
  [self.animator addBehavior:self.gravityBehavior];

  self.settingsVC = [self.childViewControllers find:^BOOL(id vc) {
    return [vc isKindOfClass:[HATSettingsViewController class]];
  }];

  self.settingsVC.view.hidden = YES;

  [self.view layoutIfNeeded];

  [self hideNewUserView:NO];
  [self hideArticleTitleView:NO];

  BOOL hasUserSeenWelcome = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownWelcome"];
  if (!hasUserSeenWelcome)
  {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [self showAboutView:HATAboutScreenContentWelcome];
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shownWelcome"];
    });
  }
}

- (void)didReceiveMemoryWarning
{
  [self.avPlayers removeAllObjects];

  for (UIView *subview in self.view.subviews)
  {
    if (![subview isKindOfClass:[HATUpdateView class]])
    {
      continue;
    }

    self.selectedView = nil;
    HATUpdateView *dotView = (HATUpdateView *)subview;
    [self.gravityBehavior removeItem:dotView];
    [UIView animateWithDuration:0.4
        animations:^{
          dotView.alpha = 0;
          dotView.transform = CGAffineTransformScale(dotView.transform, 0.1, 0.1);
        }
        completion:^(BOOL finished) {
          [self.viewsToPoints removeObjectForKey:dotView.info[@"page_title"]];
          [dotView removeFromSuperview];
        }];
  }
}

- (NSString *)currentLanguageCode
{
  return [[NSLocale preferredLanguages] objectAtIndex:0] ?: @"en";
}

- (void)animateSelectionChangeFromView:(HATUpdateView *)fromView toView:(HATUpdateView *)toView
{
  static CGPoint previousLocation = {0, 0};
  if (fromView == toView)
  {
    return;
  }

  if (fromView && fromView.superview)
  {
    fromView.alpha = 0.6;
    fromView.layer.shadowOpacity = 0;
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:fromView
                                                            snapToPoint:previousLocation];
    snapBehavior.damping = 0.85;
    [self.animator addBehavior:snapBehavior];
    [self.gravityBehavior addItem:fromView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [self.animator removeBehavior:snapBehavior];
    });
  }

  if (toView && toView.superview)
  {
    previousLocation = toView.center;

    [toView.layer pauseAnimations];
    toView.layer.shadowOpacity = 1;
    toView.layer.shadowRadius = 6;
    toView.layer.shadowOffset = CGSizeZero;
    toView.alpha = 0.85;

    [self.view insertSubview:toView belowSubview:self.userJoinedBanner];

    [self.gravityBehavior removeItem:toView];
    CGPoint toPoint = CGPointMake(
        self.view.center.x,
        CGRectGetHeight(self.view.frame) - self.view.safeAreaInsets.bottom - 34 - toView.frame.size.height / 2);
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:toView snapToPoint:toPoint];
    snapBehavior.damping = 0.85;
    [self.animator addBehavior:snapBehavior];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [self.animator removeBehavior:snapBehavior];
    });
  }
}

#pragma mark - Notifications
- (void)didEnterBackground
{
  [self.wikipediaService closeAllSockets];
}

- (void)didBecomeActive
{
  self.startTime = [NSDate date];

  for (HATWikipediaLanguage *language in [[HATSettings sharedSettings] selectedLanguages])
  {
    [self.wikipediaService openSocketForLanguage:language];
  }
}

#pragma mark - Events
- (void)backgroundClicked:(NSNotification *)notification
{
  self.selectedView = nil;
}

- (void)bubbleClicked:(NSNotification *)notification
{
  if (self.selectedView == notification.object)
  {
    self.selectedView = nil;
  }
  else
  {
    self.selectedView = notification.object;
  }
}

#pragma mark - Auxiliary Views
- (void)showNewUserView:(BOOL)animated
{
  self.userJoinedBanner.alpha = 1;
  self.isDisplayingNewUserBanner = YES;
  [UIView animateWithDuration:animated ? 0.3 : 0
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     [self updateControlOverlayConstraints];
                     [self.view layoutIfNeeded];
                     self.userJoinedBanner.transform = CGAffineTransformIdentity;
                   }
                   completion:nil];
}

- (void)hideNewUserView:(BOOL)animated
{
  self.isDisplayingNewUserBanner = NO;
  [UIView animateWithDuration:animated ? 0.3 : 0
      delay:0
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        [self updateControlOverlayConstraints];
        [self.view layoutIfNeeded];
        self.userJoinedBanner.alpha = 0;
      }
      completion:^(BOOL finished) {
        self.userJoinedBanner.transform =
            CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.userJoinedBanner.bounds));
      }];
}

- (void)showArticleTitleView:(BOOL)animated
{
  [UIView animateWithDuration:animated ? 0.3 : 0
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.articleTitleView.transform = CGAffineTransformIdentity;
                   }
                   completion:nil];
}

- (void)hideArticleTitleView:(BOOL)animated
{
  [UIView animateWithDuration:animated ? 0.3 : 0
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.articleTitleView.transform = CGAffineTransformMakeTranslation(
                         0, CGRectGetHeight(self.articleTitleView.frame));
                   }
                   completion:nil];
}

- (void)showAboutView:(HATAboutScreenContent)content
{
  [[appDelegate sidePanelController] showCenterPanelAnimated:YES];
  self.aboutVC = [[HATAboutViewController alloc] init];
  self.aboutVC.view.frame = [appDelegate sidePanelController].centerPanelContainer.frame;

  [[appDelegate sidePanelController] addChildViewController:self.aboutVC];
  [[appDelegate sidePanelController].view addSubview:self.aboutVC.view];

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

  HATUpdateView *dotView = [[HATUpdateView alloc]
      initWithFrame:CGRectMake(point.x - radius / 2, point.y - radius / 2, radius, radius)
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
      }
      completion:^(BOOL finished) {
        if (!finished)
        {
          return;
        }

        [self.gravityBehavior addItem:dotView];
        [self animateViewOut:dotView];
      }];
}

- (void)animateViewOut:(HATUpdateView *)dotView
{
  CGFloat floatDuration = 8;
  CGFloat fadeDuration = 1;
  [UIView animateWithDuration:fadeDuration
      delay:floatDuration - fadeDuration
      options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
      animations:^{
        dotView.alpha = 0;
      }
      completion:^(BOOL finished) {
        if (!finished)
        {
          return;
        }

        [self.viewsToPoints removeObjectForKey:dotView.info[@"page_title"]];
        [self.gravityBehavior removeItem:dotView];
        [dotView removeFromSuperview];
      }];
}

#pragma mark - Audio
- (void)playSoundWithPath:(NSString *)path
{
  static int numCurrentlyPlayingSounds = 0;

  if ([[HATSettings sharedSettings] soundsMuted])
  {
    return;
  }

  if (numCurrentlyPlayingSounds > kMaxSimultaneousSounds)
  {
    return;
  }

  NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
  if (!soundPath)
  {
    NSLog(@"Could not find sound file at path %@", soundPath);
    return;
  }

  NSURL *url = [NSURL fileURLWithPath:soundPath];

  NSError *error;
  AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
  if (error)
  {
    NSLog(@"error creating audio player with contents of %@: %@", url, error);
    return;
  }

  player.delegate = self;
  [self.avPlayers addObject:player];
  [player play];
  numCurrentlyPlayingSounds++;

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    numCurrentlyPlayingSounds--;
  });
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
  [self.avPlayers removeObject:player];
}

#pragma mark - HATWikipediaServiceDelegate
- (void)wikipediaServiceDidReceiveMessage:(NSString *)message
{
  NSDictionary *json = [message objectFromJSONString];
  NSString *soundPath;
  if ([json[@"page_title"] isEqualToString:@"Special:Log/newusers"])
  {
    // Don't show new user notifications during the first 20 seconds
    if ([[NSDate date] timeIntervalSinceDate:self.startTime] < 20)
    {
      return;
    }

    soundPath = [NSString stringWithFormat:@"swell%d", (rand() % kNumSwells) + 1];
    self.newestUserName = json[@"user"];
    [self.userJoinedBanner welcomeUserWithUsername:self.newestUserName];
    [self showNewUserView:YES];
  }
  else if (![[json[@"ns"] lowercaseString] isEqualToString:@"main"])
  {
    return;
  }
  else
  {
    NSNumber *changeSize = json[@"change_size"];
    if ([changeSize isKindOfClass:[NSNull class]])
    {
      return;
    }

    int index = indexForChangeSize(changeSize.doubleValue);
    //        so the clav is the bell sound, that's for additions
    //        and the celesta is the string sound, that's for subtractions
    BOOL isAddition = [changeSize intValue] > 0;
    if (isAddition)
    {
      soundPath = [NSString stringWithFormat:@"cel%03d", index];
    }
    else
    {
      soundPath = [NSString stringWithFormat:@"clav%03d", index];
    }

    CGFloat dotMin = arc4random() % 100 + 35;
    [self showViewCenteredAt:[self getRandomPoint]
               withMagnitude:MAX(labs(changeSize.integerValue), dotMin)
                     andInfo:json];
  }

  [self playSoundWithPath:soundPath];
}

#pragma mark - HATUserJoinedBannerDelegate
- (void)userJoinedBannerWantsDismiss:(HATUserJoinedBanner *)banner
{
  [self hideNewUserView:YES];
}

- (void)userJoinedBannerTapped:(HATUserJoinedBanner *)banner
{
  NSString *urlString = [NSString
      stringWithFormat:
          @"http://%@.wikipedia.org/w/index.php?title=User_talk:%@&action=edit&section=new",
          self.currentLanguageCode, banner.currentlyDisplayedUsername];
  [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:urlString]
                options:@{}
      completionHandler:nil];
}

#pragma mark - HATArticleTitleViewDelegate

- (void)articleTitleViewTapped:(HATArticleTitleView *)articleTitleView
{
  NSLog(@"articleTitleView.articleURL %@", articleTitleView.articleURL);
  [[UIApplication sharedApplication]
                openURL:articleTitleView.articleURL
                options:@{}
      completionHandler:nil];
}

@end
