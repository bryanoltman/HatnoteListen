//
//  HATAboutViewController.m
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/17/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import "HATAboutViewController.h"

#define kAboutViews 2
#define kTextPadding 20

@interface HATAboutViewController () <TTTAttributedLabelDelegate>
@property (strong, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) NSIndexPath *visibleIndexPath;
@end

@implementation HATAboutViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.dismissRecognizer.direction = DirectionPanGestureRecognizerHorizontal;

  self.backgroundView = [[UINavigationBar alloc] initWithFrame:self.view.bounds];
  self.backgroundView.alpha = 0;
  self.backgroundView.autoresizingMask =
      UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self.view insertSubview:self.backgroundView atIndex:0];

  self.collectionView.alpha = 0;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  UICollectionViewCell *visibleCell = [[self.collectionView visibleCells] first];
  self.visibleIndexPath = [self.collectionView indexPathForCell:visibleCell];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [self.collectionView reloadData];
  [self.collectionView scrollToItemAtIndexPath:self.visibleIndexPath
                              atScrollPosition:UICollectionViewScrollPositionNone
                                      animated:NO];
}

- (void)readAboutText:(NSString *)fileName
{
  NSError *err = nil;
  NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
  NSString *aboutText = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&err];

  NSArray *lines =
      [aboutText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  self.pages = [NSMutableArray new];

  NSMutableParagraphStyle *headerParagraphStyle = [NSMutableParagraphStyle new];
  headerParagraphStyle.paragraphSpacing = 15;
  headerParagraphStyle.alignment = NSTextAlignmentCenter;

  NSMutableParagraphStyle *bodyParagraphStyle = [NSMutableParagraphStyle new];
  bodyParagraphStyle.paragraphSpacing = 10;

  NSMutableParagraphStyle *ellipsisParagraphStyle = [NSMutableParagraphStyle new];
  ellipsisParagraphStyle.alignment = NSTextAlignmentCenter;

  UIFont *headerFont = [UIFont systemFontOfSize:30];
  UIFont *bodyFont = [UIFont systemFontOfSize:18];

  NSDictionary *headerAttrs =
      @{NSFontAttributeName : headerFont, NSParagraphStyleAttributeName : headerParagraphStyle};
  NSDictionary *bodyAttrs =
      @{NSFontAttributeName : bodyFont, NSParagraphStyleAttributeName : bodyParagraphStyle};
  NSDictionary *ellipsisAttrs =
      @{NSFontAttributeName : headerFont, NSParagraphStyleAttributeName : ellipsisParagraphStyle};
  NSMutableAttributedString *attrText = [NSMutableAttributedString new];

  NSUInteger page = 0;
  for (NSString *line in lines)
  {
    if ([line isEqualToString:@" "])
    {
      self.pages[page] = attrText;
      attrText = [NSMutableAttributedString new];
      page++;
      continue;
    }

    NSString *writeLine =
        [[NSString stringWithFormat:@"%@\n", line] stringByReplacingOccurrencesOfString:@"\\n"
                                                                             withString:@"\n"];
    if ([writeLine rangeOfString:@"\t"].location == 0)
    {
      // body text
      [attrText
          appendAttributedString:[[NSAttributedString alloc]
                                     initWithString:[writeLine
                                                        stringByReplacingOccurrencesOfString:@"\t"
                                                                                  withString:@""]
                                         attributes:bodyAttrs]];
    }
    else if ([writeLine isEqualToString:@"…"])
    {
      [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:writeLine
                                                                       attributes:ellipsisAttrs]];
    }
    else
    {
      // header text
      [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:writeLine
                                                                       attributes:headerAttrs]];
    }
  }

  self.pages[page] = attrText;
}

- (TTTAttributedLabel *)labelForIndex:(NSUInteger)index
{
  TTTAttributedLabel *ret = [[TTTAttributedLabel alloc]
      initWithFrame:CGRectMake(kTextPadding, kTextPadding,
                               self.view.frame.size.width - 2 * kTextPadding,
                               self.view.frame.size.height - 2 * kTextPadding)];
  ret.delegate = self;
  [ret setLinkAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.5 alpha:1]}];
  ret.numberOfLines = 0;
  ret.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  ret.attributedText = [self pageForIndex:index];

  NSRange range = [ret.attributedText.string rangeOfString:@"Bryan Oltman"];
  [ret addLinkToURL:[NSURL URLWithString:@"http://bryanoltman.com/"] withRange:range];

  range = [ret.attributedText.string rangeOfString:@"Hatnote's Listen to Wikipedia"];
  [ret addLinkToURL:[NSURL URLWithString:@"http://listen.hatnote.com"] withRange:range];

  return ret;
}

- (NSAttributedString *)pageForIndex:(NSUInteger)index
{
  if (self.pages.count <= index)
  {
    return nil;
  }

  return self.pages[index];
}

- (CGFloat)backgroundAlpha
{
  return 0.9f;
}

- (void)show:(HATAboutScreenContent)content
{
  self.contentType = content;

  switch (content)
  {
    case HATAboutScreenContentWelcome:
      //            [Flurry logEvent:@"welcome_page_viewed"];
      [self readAboutText:@"welcome"];
      break;
    case HATAboutScreenContentTutorial:
      //            [Flurry logEvent:@"tutorial_page_viewed"];
      [self readAboutText:@"tutorial"];
      break;
    case HATAboutScreenContentAbout:
      //            [Flurry logEvent:@"about_page_viewed"];
      [self readAboutText:@"about"];
      break;
    default:
      break;
  }

  [self show];
}

- (void)show
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
  [UIView animateWithDuration:0.4
                        delay:0.3
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.backgroundView.alpha = [self backgroundAlpha];
                     self.collectionView.alpha = 1;
                   }
                   completion:nil];
}

- (void)hide:(void (^)(void))complated
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  [UIView animateWithDuration:0.2
      delay:0
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        self.backgroundView.alpha = self.collectionView.alpha = 0;
      }
      completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
      }];
}

- (void)panned:(UIPanGestureRecognizer *)sender
{
  switch (sender.state)
  {
    case UIGestureRecognizerStateChanged:
    {
      CGPoint trans = [sender translationInView:self.view];
      if (fabs(trans.y) > 10 && fabs(trans.y) > fabs(trans.x) * 2)
      {
        [sender setEnabled:NO];
        [sender setEnabled:YES];
        return;
      }

      self.collectionView.transform = CGAffineTransformMakeTranslation(trans.x, 0);
      self.backgroundView.alpha = self.collectionView.alpha =
          [self backgroundAlpha] - (fabs(trans.x) / self.collectionView.frame.size.width);
    }
    break;
    case UIGestureRecognizerStateCancelled:
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateFailed:
    {
      CGPoint trans = [sender translationInView:self.collectionView];
      CGFloat xVelocity = [sender velocityInView:self.view].x;
      if (fabs(trans.x) > 160 || fabs(xVelocity) > 750)
      {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                           self.collectionView.transform =
                               CGAffineTransformMakeTranslation(xVelocity, 0);
                         }
                         completion:nil];
        [self hide:nil];
      }
      else
      {
        [UIView animateWithDuration:0.4
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.3
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           self.collectionView.transform = CGAffineTransformIdentity;
                           self.backgroundView.alpha = self.collectionView.alpha =
                               [self backgroundAlpha];
                         }
                         completion:nil];
      }
    }
    break;
    default:
      break;
  }
}

#pragma mark - UICollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AboutCell"
                                                                         forIndexPath:indexPath];
  for (UIView *subview in [cell subviews])
  {
    [subview removeFromSuperview];
  }

  [cell addSubview:[self labelForIndex:indexPath.row]];

  if (self.contentType == HATAboutScreenContentWelcome && indexPath.row == self.pages.count - 1)
  {
    // bounce menu
    [UIView
        animateKeyframesWithDuration:0.3
                               delay:1
                             options:UIViewKeyframeAnimationOptionAutoreverse
                          animations:^{
                            [UIView
                                addKeyframeWithRelativeStartTime:0
                                                relativeDuration:1
                                                      animations:^{
                                                        [[[appDelegate container]
                                                            centerPanelContainer]
                                                            setTransform:
                                                                CGAffineTransformMakeTranslation(
                                                                    30, 0)];
                                                      }];
                          }
                          completion:nil];
    [[[appDelegate container] centerPanelContainer] setTransform:CGAffineTransformIdentity];
  }

  return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return self.pages.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return self.collectionView.bounds.size;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
  [[UIApplication sharedApplication]
                openURL:url
                options:@{}
      completionHandler:nil];
}

@end
