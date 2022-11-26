//
//  HATArticleTitleView.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/25/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HATArticleTitleView;

@protocol HATArticleTitleViewDelegate <NSObject>
- (void)articleTitleViewTapped:(HATArticleTitleView *)articleTitleView;
@end

@interface HATArticleTitleView : UIView

@property (weak, nonatomic) id<HATArticleTitleViewDelegate> delegate;
@property (readonly, nonatomic, copy) NSURL *articleURL;

- (void)setText:(NSString *)text url:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
