//
//  GBTabBarController.h
//  Lyfe
//
//  Created by aarthur on 7/22/15.
//  Copyright (c) 2015 GB. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *NAV_BAR_TITLE_KEY;
extern NSString *TAB_BAR_TITLE_KEY;
extern NSString *TAB_BAR_TYPE_KEY;
extern NSString *TAB_ITEM_IMAGE_KEY;

@interface GBTabBarController : UITabBarController

+ (NSArray*)quickActionItemsInfo;
+ (NSArray*)storyBoardNames;
- (UINavigationController*)viewControllerForTabWithTitle:(NSString*)tabTitle;

@end
