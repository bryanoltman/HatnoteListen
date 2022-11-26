//
//  HATNewUserView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/24/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import "HATUserJoinedBanner.h"
#import <Masonry/Masonry.h>

#define kBannerDuration 10.0

@interface HATUserJoinedBanner ()

@property (strong, nonatomic) NSTimer *messageTimer;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) NSMutableArray<NSString *> *userQueue;

@end

@implementation HATUserJoinedBanner

- (NSString *)welcomeMessageForUsername:(NSString *)username
{
  static NSArray *welcomeMessageTemplates = nil;
  if (!welcomeMessageTemplates)
  {
    welcomeMessageTemplates = @[
      @"Welcome to %@, Wikipedia's newest user!", @"Wikipedia has a new user, %@! Welcome!",
      @"%@ has joined Wikipedia!"
    ];
  }

  return [NSString stringWithFormat:[welcomeMessageTemplates randomObject], username];
}

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    self.userQueue = [[NSMutableArray alloc] init];

    self.backgroundColor = [UIColor userJoinedBannerColor];

    self.userNameLabel = [[UILabel alloc] init];
    [self addSubview:self.userNameLabel];
    self.userNameLabel.textColor = [UIColor whiteColor];
    self.userNameLabel.numberOfLines = 0;
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;

    CGFloat topSafeAreaInset = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.top;

    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self).offset(8.0 + topSafeAreaInset);
      make.leading.trailing.bottom.equalTo(self).inset(8.0);
    }];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapRecognizer];
  }
  return self;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer
{
  [self.delegate userJoinedBannerTapped:self];
}

- (void)welcomeUserWithUsername:(NSString *)username
{
  [self.userQueue addObject:username];

  if (self.messageTimer.isValid)
  {
    return;
  }

  [self welcomeNextUserInQueue];
}

- (void)welcomeNextUserInQueue
{
  self.currentlyDisplayedUsername = [self.userQueue firstObject];
  if (!self.currentlyDisplayedUsername)
  {
    // If we have no more users to welcome, ask our delegate to dismiss us.
    [self.delegate userJoinedBannerWantsDismiss:self];
    return;
  }

  [self.userQueue removeObjectAtIndex:0];
  self.userNameLabel.text = [self welcomeMessageForUsername:self.currentlyDisplayedUsername];
  self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:kBannerDuration
                                                      repeats:NO
                                                        block:^(NSTimer *_Nonnull timer) {
                                                          [self welcomeNextUserInQueue];
                                                        }];
}

@end
