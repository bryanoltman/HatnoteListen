//
//  HATViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 2/23/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATViewController.h"
#import "HATSettingsViewController.h"
#import "HATUpdateView.h"
#import "HATWikipediaService.h"
#import "HATWikipediaViewController.h"

#define kNumClav 27
#define kNumCelesta 27
#define kNumSwells 3

@interface HATViewController () <HATWikipediaServiceDelegate>
@property (strong, nonatomic) FBKVOController *KVOController;
@property (strong, nonatomic) HATWikipediaViewController *wikiVC;
@property (strong, nonatomic) HATSettingsViewController *settingsVC;
@property (strong, nonatomic) NSMutableArray *avPlayers;
@property (strong, nonatomic) NSTimer *wikiHideTimer;
@property (strong, nonatomic) NSTimer *userHideTimer;
@property (strong, nonatomic) NSTimer *pushBehaviorTimer;
@property (strong, nonatomic) NSString *newestUserName;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) NSMutableDictionary *viewsToPoints;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) HATWikipediaService *wikipediaService;

@property (strong, nonatomic) HATUpdateView *selectedView;
@end

@implementation HATViewController

+ (NSArray *)newUserMessages
{
  static NSArray *ret = nil;
  if (!ret)
  {
    ret = @[
      @"Welcome to %@, Wikipedia's newest user!", @"Wikipedia has a new user, %@! Welcome!",
      @"%@ has joined Wikipedia!"
    ];
  }

  return ret;
}

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
              [change[NSKeyValueChangeNewKey] each:^(HATWikipediaLanguage *lang) {
                [weakSelf.wikipediaService openSocketForLanguage:lang];
              }];
            }
            else if (kind == NSKeyValueChangeRemoval)
            {
              [change[NSKeyValueChangeOldKey] each:^(HATWikipediaLanguage *lang) {
                [weakSelf.wikipediaService closeSocketForLanguage:lang];
              }];
            }
          }];

    [self.KVOController
        observe:[appDelegate container]
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
  self.wikiVC.info = _selectedView.info;
  if (_selectedView)
  {
    [self showWikiView:YES];
  }
  else
  {
    [self hideWikiView:YES];
  }

  [self animateSelectionChangeFromView:previousView toView:selectedView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor backgroundColor];

  self.userView.backgroundColor = [UIColor bannerTintColor];
  [self.userView addSubview:self.userLabel];
  [self.view addSubview:self.userView];

  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

  self.gravityBehavior = [UIGravityBehavior new];
  self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
  self.gravityBehavior.magnitude = 0.01;
  [self.animator addBehavior:self.gravityBehavior];

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
  if (!hasUserSeenWelcome)
  {
    [self
        performBlock:^{
          [self showAboutView:HATAboutScreenContentWelcome];
          [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shownWelcome"];
          [[NSUserDefaults standardUserDefaults] synchronize];
        }
          afterDelay:0.2];
  }

  self.pushBehaviorTimer =
      [NSTimer scheduledTimerWithTimeInterval:1
                                       target:self
                                     selector:@selector(pushBehaviorTimerTicked:)
                                     userInfo:nil
                                      repeats:YES];
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
    [self
        performBlock:^{
          [self.animator removeBehavior:snapBehavior];
        }
          afterDelay:0.5];
  }

  if (toView && toView.superview)
  {
    previousLocation = toView.center;

    [toView.layer pauseAnimations];
    toView.layer.shadowOpacity = 1;
    toView.layer.shadowRadius = 6;
    toView.layer.shadowOffset = CGSizeZero;
    toView.alpha = 0.85;

    [self.view insertSubview:toView belowSubview:self.wikiVC.view.superview];

    [self.gravityBehavior removeItem:toView];
    CGPoint toPoint = self.view.center;
    toPoint.y = CGRectGetMinY(self.wikiVC.view.superview.frame) - toView.frame.size.height / 2;
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:toView snapToPoint:toPoint];
    snapBehavior.damping = 0.85;
    [self.animator addBehavior:snapBehavior];
    [self
        performBlock:^{
          [self.animator removeBehavior:snapBehavior];
        }
          afterDelay:0.5];
  }
}

#pragma mark - Notifications
- (void)didEnterBackground
{
  [self.wikipediaService closeAllSockets];
  self.selectedView = nil;
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
  self.selectedView = notification.object;
}

- (void)newUserViewTapped:(UITapGestureRecognizer *)recognizer
{
  NSString *urlString = [NSString
      stringWithFormat:
          @"http://%@.wikipedia.org/w/index.php?title=User_talk:%@&action=edit&section=new",
          self.currentLanguageCode, self.newestUserName];
  [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:urlString]
                options:@{}
      completionHandler:nil];
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
                   }
                   completion:nil];

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
      }
      completion:^(BOOL finished) {
        self.userView.transform =
            CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.userView.bounds));
      }];
}

- (void)showWikiView:(BOOL)animated
{
  [UIView animateWithDuration:animated ? 0.3 : 0
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.wikiVC.view.transform = CGAffineTransformIdentity;
                   }
                   completion:nil];

  [self.wikiHideTimer invalidate];
  self.wikiHideTimer = [NSTimer scheduledTimerWithTimeInterval:9
                                                        target:self
                                                      selector:@selector(removeTimerTicked:)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)removeTimerTicked:(NSTimer *)timer
{
  if (timer == self.userHideTimer)
  {
    [self hideNewUserView:YES];
  }
  else if (timer == self.wikiHideTimer)
  {
    [self hideWikiView:YES];
  }
}

- (void)pushBehaviorTimerTicked:(NSTimer *)timer
{
  // TODO
  //    NSUInteger index = arc4random() % self.view.subviews.count;
  //    UIView *subview = self.view.subviews[index];
  //    if (![subview isKindOfClass:[HATUpdateView class]]) {
  //        return;
  //    }
  //
  //    HATUpdateView *dotView = (HATUpdateView *)subview;
  //
  //    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[dotView]
  //                                                                    mode:UIPushBehaviorModeInstantaneous];
  //    pushBehavior.angle = drand48() * M_PI * 2;
  //    pushBehavior.magnitude = drand48() * 0.1;
  //    NSLog(@"push direction is %f,%f", pushBehavior.pushDirection.dx,
  //    pushBehavior.pushDirection.dy); [self.animator addBehavior:pushBehavior]; [self
  //    performBlock:^{
  //        [self.animator removeBehavior:pushBehavior];
  //    } afterDelay:0.001];
}

- (void)hideWikiView:(BOOL)animated
{
  [UIView animateWithDuration:animated ? 0.3 : 0
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.wikiVC.view.transform = CGAffineTransformMakeTranslation(
                         0, CGRectGetHeight(self.wikiVC.view.frame));
                   }
                   completion:nil];
}

- (void)showAboutView:(HATAboutScreenContent)content
{
  [[appDelegate container] showCenterPanelAnimated:YES];
  self.aboutVC = [[UIStoryboard storyboardWithName:@"About"
                                            bundle:nil] instantiateInitialViewController];
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
  if ([[HATSettings sharedSettings] soundsMuted])
  {
    return;
  }

  NSString *soundPath = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
  if (!soundPath)
  {
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
    NSString *message = [[HATViewController newUserMessages] randomObject];
    self.newestUserName = json[@"user"];
    self.userLabel.text = [NSString stringWithFormat:message, self.newestUserName];
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

    int index = CLAMP(1, (fabsf(changeSize.floatValue) / 500.f) * kNumCelesta, kNumCelesta);
    index = kNumCelesta - index + 1;

    //        so the clav is the bell sound, that's for additions
    //        and the celesta is the string sound, that's for subtractions
    BOOL isAddition = [changeSize intValue] > 0;
    if (isAddition)
    {
      soundPath = [NSString stringWithFormat:@"clav%03d", index];
    }
    else
    {
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
