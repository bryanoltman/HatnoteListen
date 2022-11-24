//
//  HATAboutViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/17/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HATHorizontalPanGestureRecognizer.h"
#import "TTTAttributedLabel.h"

typedef NS_OPTIONS(NSUInteger, HATAboutScreenContent) {
  HATAboutScreenContentWelcome,
  HATAboutScreenContentTutorial,
  HATAboutScreenContentAbout
};

@interface HATAboutViewController : UIViewController <UICollectionViewDataSource,
                                                      UICollectionViewDelegate,
                                                      UICollectionViewDelegateFlowLayout,
                                                      UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic) HATAboutScreenContent contentType;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HATHorizontalPanGestureRecognizer *dismissRecognizer;

- (void)show:(HATAboutScreenContent)content;

- (void)hide:(void (^)(void))complated;

- (IBAction)panned:(UIPanGestureRecognizer *)sender;

@end
