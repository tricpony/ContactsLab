//
//  GBSplitViewController.h
//  ClinicalTrials
//
//  Created by aarthur on 5/19/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GBDetailViewControllerCoordination <NSObject>

@required
@property (readonly, nonatomic) NSString *storyboardIDForPlaceholderScene;

@end

@interface GBSplitViewController : UISplitViewController
@property (readonly, nonatomic) UITabBarController *tabBarController;

- (void)assignNextActiveForwardDelegate:(id <UISplitViewControllerDelegate>)object;
- (void)showInitialDetailViewControllerForPrimary:(UIViewController <GBDetailViewControllerCoordination> *)primaryVC;

@end
