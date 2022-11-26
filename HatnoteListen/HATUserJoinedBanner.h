//
//  HATNewUserView.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/24/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HATUserJoinedBanner;

@protocol HATUserJoinedBannerDelegate <NSObject>
- (void)userJoinedBannerTapped:(HATUserJoinedBanner *)banner;
- (void)userJoinedBannerWantsDismiss:(HATUserJoinedBanner *)banner;
@end

@interface HATUserJoinedBanner : UIView

@property (weak, nonatomic, nullable) id<HATUserJoinedBannerDelegate> delegate;
@property (strong, nonatomic, nullable) NSString *currentlyDisplayedUsername;

- (void)welcomeUserWithUsername:(NSString *)username;

@end

NS_ASSUME_NONNULL_END
