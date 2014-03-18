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

@interface HATAboutViewController ()
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
    NSError* err = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"about%@", @(index)]
                                                     ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:&err];
    if (err) {
        // do something
        return nil;
    }
    
    NSDictionary *textOptions = @{
                                  NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                                  NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)
                                  };
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:textOptions
                                                         documentAttributes:nil
                                                                      error:&err];
    if (err) {
        // do something
        return nil;
    }
    
    TTTAttributedLabel *ret = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kTextPadding, kTextPadding,
                                                                                  self.view.frame.size.width - 2*kTextPadding,
                                                                                   self.view.frame.size.height - 2*kTextPadding)];
    ret.numberOfLines = 0;
    ret.font = [UIFont systemFontOfSize:32];
    
    [ret setLinkAttributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
    
    [ret setText:attrText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        [mutableAttributedString addAttributes:@{kTTTBackgroundCornerRadiusAttributeName: @(5),
                                                 (NSString *)kCTFontSizeAttribute : @(32)}
                                         range:[mutableAttributedString range]];
        return mutableAttributedString;
    }];
    
    if (index == 0) {
        NSRange range = [attrText.string rangeOfString:@"Bryan Oltman"];
        [ret addLinkToURL:[NSURL URLWithString:@"http://bryanoltman.com/"] withRange:range];
        
        range = [attrText.string rangeOfString:@"Hatnote's Listen to Wikipedia"];
        [ret addLinkToURL:[NSURL URLWithString:@"http://listen.hatnote.com"] withRange:range];
    }
    
    return ret;
}

- (void)show:(void(^)(void))complated
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundView.alpha = 0.6;
                     } completion:^(BOOL finished) {
//                         [self performBlock:^{
//                             [UIView animateKeyframesWithDuration:0.4
//                                                            delay:0
//                                                          options:UIViewKeyframeAnimationOptionAllowUserInteraction|UIViewKeyframeAnimationOptionCalculationModeCubic
//                                                       animations:^{
//                                                           [UIView addKeyframeWithRelativeStartTime:0
//                                                                                   relativeDuration:0.9
//                                                                                         animations:^{
//                                                                                             self.carousel.transform = CGAffineTransformMakeTranslation(0, -20);
//                                                                                         }];
//                                                           
//                                                           [UIView addKeyframeWithRelativeStartTime:0.9
//                                                                                   relativeDuration:0.1
//                                                                                         animations:^{
//                                                                                             self.carousel.transform = CGAffineTransformIdentity;
//                                                                                         }];
//                                                       } completion:nil];
//                         } afterDelay:0.2];
                     }];
}

- (void)hide:(void(^)(void))complated
{
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
