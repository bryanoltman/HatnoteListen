//
//  HATControlOverlayView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/27/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import "HATControlOverlayView.h"

static NSString *kMutedIconName = @"speaker.slash.fill";
static NSString *kUnmutedIconName = @"speaker.fill";
static NSString *kSettingsIconName = @"gearshape.fill";
static CGFloat kButtonSize = 42;
static CGFloat kIconPointSize = 24;

@interface HATControlOverlayView ()
@property (strong, nonatomic) FBKVOController *KVOController;
@property (strong, nonatomic) UIButton *muteButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIImageSymbolConfiguration *symbolConfiguration;
@end

@implementation HATControlOverlayView
- (instancetype)init
{
  self = [super init];
  if (self)
  {
    self.symbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:kIconPointSize];
    self.muteButton = [self roundIconButton:[self muteButtonImage]];
    [self.muteButton addTarget:self
                        action:@selector(muteButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.height.width.equalTo(@(kButtonSize));
    }];

    self.settingsButton = [self roundIconButton:[self settingsButtonImage]];
    [self.settingsButton addTarget:self
                            action:@selector(settingsButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.settingsButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.height.width.equalTo(@(kButtonSize));
    }];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 12.0;
    [stackView addArrangedSubview:self.settingsButton];
    [stackView addArrangedSubview:self.muteButton];

    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    __weak HATControlOverlayView *weakSelf = self;
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:[HATSettings sharedSettings]
                        keyPath:@"soundsMuted"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                            [weakSelf updateMuteButtonImage];
                          }];
  }
  return self;
}

- (UIButton *)roundIconButton:(UIImage *)image
{
  UIButton *button = [[UIButton alloc] init];
  button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
  button.tintColor = [UIColor blackColor];
  button.layer.cornerRadius = kButtonSize / 2.0;
  [button setImage:image
          forState:UIControlStateNormal];
  return button;
}

- (UIImage *)imageWithSystemName:(NSString *)systemName
{
  return [UIImage systemImageNamed:systemName withConfiguration:self.symbolConfiguration];
}

- (UIImage *)muteButtonImage
{
  NSString *iconName = HATSettings.sharedSettings.soundsMuted ? kMutedIconName : kUnmutedIconName;
  return [self imageWithSystemName:iconName];
}

- (UIImage *)unmuteButtonImage
{
  return [self imageWithSystemName:kUnmutedIconName];
}

- (UIImage *)settingsButtonImage
{
  return [self imageWithSystemName:kSettingsIconName];
}

- (void)updateMuteButtonImage
{
  [self.muteButton setImage:[self muteButtonImage] forState:UIControlStateNormal];
}

- (void)settingsButtonTapped:(id)sender
{
  [appDelegate.sidePanelController showLeftPanelAnimated:YES];
}

- (void)muteButtonTapped:(id)sender
{
  HATSettings.sharedSettings.soundsMuted = !HATSettings.sharedSettings.soundsMuted;
  [self updateMuteButtonImage];
}

@end
