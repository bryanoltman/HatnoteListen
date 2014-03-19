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
@end

@implementation HATAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundView = [[UINavigationBar alloc] initWithFrame:self.view.bounds];
    self.backgroundView.alpha = 0;
    [self.view insertSubview:self.backgroundView atIndex:0];
}

- (TTTAttributedLabel *)labelForIndex:(NSUInteger)index
{
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    TTTAttributedLabel *ret = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kTextPadding, kTextPadding,
                                                                                   self.view.frame.size.width - 2*kTextPadding,
                                                                                   self.view.frame.size.height - 2*kTextPadding)];
    ret.delegate = self;
    [ret setLinkAttributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    ret.numberOfLines = 0;
    
    NSMutableParagraphStyle *headerParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    headerParagraphStyle.paragraphSpacing = 15;

    NSMutableParagraphStyle *bodyParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    bodyParagraphStyle.paragraphSpacing = 10;
    
    UIFont *headerFont = [UIFont systemFontOfSize:30];
    UIFont *bodyFont = [UIFont systemFontOfSize:18];
    
    NSDictionary *headerAttrs = @{NSFontAttributeName:headerFont,
                                  NSParagraphStyleAttributeName:headerParagraphStyle};
    NSDictionary *bodyAttrs = @{NSFontAttributeName:bodyFont,
                                NSParagraphStyleAttributeName:bodyParagraphStyle};
    switch (index) {
        case 0: {
            NSAttributedString *line = [[NSAttributedString alloc] initWithString:@"Listen to Wikipedia\n"
                                                                       attributes:headerAttrs];
            [attrText appendAttributedString:line];
            
            line = [[NSAttributedString alloc] initWithString:@"Developed by Bryan Oltman\nInspired by Hatnote's Listen to Wikipedia"
                                                   attributes:bodyAttrs];
            [attrText appendAttributedString:line];
            
            [ret setAttributedText:attrText];

            NSRange range = [attrText.string rangeOfString:@"Bryan Oltman"];
            [ret addLinkToURL:[NSURL URLWithString:@"http://bryanoltman.com/"] withRange:range];
            
            range = [attrText.string rangeOfString:@"Hatnote's Listen to Wikipedia"];
            [ret addLinkToURL:[NSURL URLWithString:@"http://listen.hatnote.com"] withRange:range];
        }
            break;
        case 1: {
            NSAttributedString *line = [[NSAttributedString alloc] initWithString:@"Colors and Sounds\n"
                                                                       attributes:headerAttrs];
            [attrText appendAttributedString:line];
            
            line = [[NSAttributedString alloc] initWithString:@"Bells are additions, strings are subtractions. There’s something reassuring about knowing that every user makes a noise, every edit has a voice in the roar.\nGreen circles are anonymous edits\nPurple circles are bots\nWhite circles are brought to you by Registered Users Like You"
                                                   attributes:bodyAttrs];
            
            [attrText appendAttributedString:line];
            
            [ret setAttributedText:attrText];
        }
            break;
        default:
            break;
    }
    
    return ret;
}

- (void)show:(void(^)(void))complated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundView.alpha = 0.925;
                     } completion:^(BOOL finished) {
                         CGFloat duration = 0.3;
                         [CAAnimation addAnimationToLayer:self.collectionView.layer
                                                 duration:duration
                                                transform:CATransform3DMakeTranslation(0, -30, 0)
                                           easingFunction:CAAnimationEasingFunctionEaseOutCubic];
                         
                         [self performBlock:^{
                             [CAAnimation addAnimationToLayer:self.collectionView.layer
                                                     duration:0.7
                                                    transform:CATransform3DIdentity
                                               easingFunction:CAAnimationEasingFunctionEaseOutQuintic];
                         } afterDelay:duration];
                     }];
}

- (void)hide:(void(^)(void))complated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundView.alpha = self.collectionView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

#pragma mark - UICollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AboutCell"
                                                                           forIndexPath:indexPath];
    for (UIView *subview in [cell subviews]) {
        [subview removeFromSuperview];
    }
    
    [cell addSubview:[self labelForIndex:indexPath.row]];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kAboutViews;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

@end
