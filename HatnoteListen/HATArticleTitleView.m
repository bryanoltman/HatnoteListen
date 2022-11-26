//
//  HATArticleTitleView.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 11/25/22.
//  Copyright © 2022 Bryan Oltman. All rights reserved.
//

#import "HATArticleTitleView.h"

#import <Masonry/Masonry.h>
#import "UIColor+Theme.h"

@interface HATArticleTitleView ()

@property (nonatomic, copy) NSURL *articleURL;
@property (strong, nonatomic) UILabel *textLabel;

@end

@implementation HATArticleTitleView

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    CGFloat bottomSafeAreaInset = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;

    self.backgroundColor = [UIColor articleTitleViewBackgroundColor];
    self.userInteractionEnabled = YES;

    self.textLabel = [[UILabel alloc] init];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.leading.top.trailing.equalTo(self).inset(8.0);
      make.bottom.equalTo(self).inset(8 + bottomSafeAreaInset);
    }];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapRecognizer];
  }
  return self;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer
{
  [self.delegate articleTitleViewTapped:self];
}

- (void)setText:(NSString *)text url:(NSURL *)url
{
  self.textLabel.text = text;
  self.articleURL = url;
}

@end
