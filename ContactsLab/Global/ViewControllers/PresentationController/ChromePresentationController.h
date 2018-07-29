//
//  ChromePresentationController.h
//  ClinicalTrials
//
//  Created by aarthur on 5/24/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChromePresentationController : UIPresentationController <UISplitViewControllerDelegate>
@property (nonatomic, assign) CGFloat sizeFactorReduceTo;

@end

@interface ChromeTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end
