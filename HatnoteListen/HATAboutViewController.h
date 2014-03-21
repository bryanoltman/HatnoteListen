//
//  HATAboutViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/17/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "HATHorizontalPanGestureRecognizer.h"

@interface HATAboutViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HATHorizontalPanGestureRecognizer *dismissRecognizer;

- (void)showWelcome;
- (void)show:(void(^)(void))complated;
- (void)hide:(void(^)(void))complated;

- (IBAction)panned:(UIPanGestureRecognizer *)sender;

@end
