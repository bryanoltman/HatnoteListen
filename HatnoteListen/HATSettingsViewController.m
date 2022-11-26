//
//  HATSettingsViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/10/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATSettingsViewController.h"

#define kSettingsSection 0
#define kSettingsSectionTextVolume 0
#define kSettingsSectionSounds 1

#define kLanguageSection 1

#define kAboutSection 2
#define kAboutSectionTutorial 0
#define kAboutSectionAbout 1

#define kTextVolumeSheet 10000

@interface HATSettingsViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) FBKVOController *kvoController;
@end

@implementation HATSettingsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[appDelegate sidePanelController] setLeftFixedWidth:self.tableView.frame.size.width + 5];
  self.kvoController = [FBKVOController controllerWithObserver:self];

  __weak HATSettingsViewController *weakSelf = self;
  [self.kvoController observe:[HATSettings sharedSettings]
                      keyPath:@"textVolume"
                      options:NSKeyValueObservingOptionNew
                        block:^(id observer, id object, NSDictionary *change) {
                          [weakSelf.tableView
                                reloadSections:[[NSIndexSet alloc] initWithIndex:kSettingsSection]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        }];
}

- (void)soundSwitchToggled:(UISwitch *)sender
{
  [[HATSettings sharedSettings] setSoundsMuted:!sender.on];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (actionSheet.tag == kTextVolumeSheet)
  {
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
      [[HATSettings sharedSettings] setTextVolume:buttonIndex];
    }
  }
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case kLanguageSection:
      return [[HATSettings availableLanguages] count];
    case kSettingsSection:
      return 2;
    case kAboutSection:
      return 2;
  }

  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell;
  if (indexPath.section == kLanguageSection)
  {
    cell = [tableView dequeueReusableCellWithIdentifier:[HATLanguageTableViewCell reuseId]];
    HATLanguageTableViewCell *hatLanguageCell = (HATLanguageTableViewCell *)cell;
    hatLanguageCell.language = [HATSettings availableLanguages][[indexPath row]];
  }
  else if (indexPath.section == kAboutSection)
  {
    static NSString *reuseId = @"AboutCell";
    cell = [tableView dequeueReusableCellWithIdentifier:reuseId];

    switch (indexPath.row)
    {
      case kAboutSectionTutorial:
        cell.textLabel.text = @"Tutorial";
        break;
      case kAboutSectionAbout:
      {
        cell.textLabel.text = @"About";
      }
      break;
      default:
        break;
    }
  }
  else if (indexPath.section == kSettingsSection)
  {
    switch (indexPath.row)
    {
      case kSettingsSectionTextVolume:
      {
        static NSString *reuseId = @"SettingsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        cell.textLabel.text = @"Text Volume";
        cell.detailTextLabel.text =
            [self displayStringForHATTextVolume:[[HATSettings sharedSettings] textVolume]
                                   showSelected:NO];
      }
      break;
      case kSettingsSectionSounds:
      {
        static NSString *reuseId = @"SoundsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        UISwitch *switchView = [cell.contentView.subviews find:^BOOL(UIView *subview) {
          return [subview isKindOfClass:[UISwitch class]];
        }];

        switchView.on = ![[HATSettings sharedSettings] soundsMuted];
        [switchView addTarget:self
                       action:@selector(soundSwitchToggled:)
             forControlEvents:UIControlEventValueChanged];
      }
      break;
      default:
        break;
    }
  }

  return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == kLanguageSection)
  {
    return NO;
  }

  return YES;
}

- (NSString *)displayStringForHATTextVolume:(HATTextVolume)textVolume
                               showSelected:(BOOL)showSelected
{
  NSString *ret = nil;
  switch (textVolume)
  {
    case HATTextVolumeNone:
      ret = @"No Text";
      break;
    case HATTextVolumeSome:
      ret = @"Some Text";
      break;
    case HATTextVolumeLots:
      ret = @"Lots of Text";
      break;
    case HATTextVolumeAll:
      ret = @"All Text";
      break;
    case HATTextVolumeCount:
      ret = @"!!!MAX!!!";
      break;
    default:
      break;
  }

  if (showSelected && textVolume == [[HATSettings sharedSettings] textVolume])
  {
    ret = [NSString stringWithFormat:@"%@\342\234\223", ret];
  }

  return ret;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == kSettingsSection)
  {
    switch (indexPath.row)
    {
      case kSettingsSectionTextVolume:
      {
        UIActionSheet *actionSheet = [UIActionSheet new];
        actionSheet.tag = kTextVolumeSheet;
        actionSheet.delegate = self;
        for (int i = 0; i < HATTextVolumeCount; i++)
        {
          [actionSheet addButtonWithTitle:[self displayStringForHATTextVolume:i showSelected:YES]];
        }

        [actionSheet addButtonWithTitle:@"Cancel"];
        actionSheet.cancelButtonIndex = HATTextVolumeCount;

        [actionSheet showInView:self.view];
      }
      break;

      default:
        break;
    }
  }
  else if (indexPath.section == kAboutSection)
  {
    switch (indexPath.row)
    {
      case kAboutSectionTutorial:
      {
        [[appDelegate viewController] showAboutView:HATAboutScreenContentTutorial];
      }
      break;
      case kAboutSectionAbout:
      {
        [[appDelegate viewController] showAboutView:HATAboutScreenContentAbout];
      }
      break;
      default:
        break;
    }
  }
}

@end
