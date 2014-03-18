//
//  HATAboutViewController.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/17/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface HATAboutViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)show:(void(^)(void))complated;
- (void)hide:(void(^)(void))complated;

@end
