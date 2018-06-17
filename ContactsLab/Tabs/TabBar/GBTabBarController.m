//
//  GBTabBarController.m
//  Lyfe
//
//  Created by aarthur on 7/22/15.
//  Copyright (c) 2015 GB. All rights reserved.
//

#import "GBTabBarController.h"
#import "CoreDataUtility.h"

@interface GBTabBarController ()

@end

NSString *localizationForString(NSString *englishString)
{
    return NSLocalizedString(englishString, @"tab bar item title");
}

NSString *NAV_BAR_TITLE_KEY = @"NAV_BAR_TITLE_KEY";
NSString *TAB_BAR_TITLE_KEY = @"TAB_BAR_TITLE_KEY";
NSString *TAB_BAR_TYPE_KEY = @"TAB_BAR_TYPE_KEY";
NSString *TAB_ITEM_IMAGE_KEY = @"TAB_ITEM_IMAGE_KEY";
@implementation GBTabBarController

+ (NSArray*)quickActionItemsInfo
{
    NSPredicate *q;
    
    q = [[CoreDataUtility sharedInstance] notEqualToPredicateForKey:TAB_BAR_TITLE_KEY andValue:@"Search"];
    return [[self storyBoardNames] filteredArrayUsingPredicate:q];
}

+ (NSArray*)storyBoardNames
{
    return @[
             @{NAV_BAR_TITLE_KEY:@"Search Contacts",
               TAB_ITEM_IMAGE_KEY:@"icon_search.png",
               TAB_BAR_TITLE_KEY:localizationForString(@"Search")
               },
             @{NAV_BAR_TITLE_KEY:@"Brands",
               TAB_ITEM_IMAGE_KEY:@"support_blue.png",
               TAB_BAR_TITLE_KEY:localizationForString(@"Brands")
               }
             ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    int i = 0;
    NSArray *storyBoardNames = [[self class] storyBoardNames];
    
    //the storyboard should do this for me but it fails
    //using brute force here
    while (i < [self.viewControllers count]) {
        UINavigationController *navVC = self.viewControllers[i];
        UIViewController *vc = navVC.topViewController;
        NSDictionary *infoNode = storyBoardNames[i];
        NSString *tabImageName = infoNode[TAB_ITEM_IMAGE_KEY];
        NSString *navTitle = infoNode[NAV_BAR_TITLE_KEY];
        NSString *tabTitle = infoNode[TAB_BAR_TITLE_KEY];

        if (tabImageName) {
            navVC.tabBarItem.image = [UIImage imageNamed:tabImageName];
        }
        vc.title = navTitle;
        navVC.navigationItem.title = navTitle;
        navVC.tabBarItem.title = tabTitle;
        ++i;
    }
    
}

- (UINavigationController*)viewControllerForTabWithTitle:(NSString*)tabTitle
{
    NSInteger tabIndex;
    NSPredicate *q;
    NSDictionary *matchingItem;
    NSArray *items = [[self class] storyBoardNames];
    
    q = [[CoreDataUtility sharedInstance] equalToPredicateForKey:TAB_BAR_TITLE_KEY andValue:tabTitle];
    matchingItem = [[items filteredArrayUsingPredicate:q] lastObject];
    tabIndex = [items indexOfObject:matchingItem];
    
    if (tabIndex > [self.viewControllers count]) {
        return nil;
    }
    
    return self.viewControllers[tabIndex];
}

@end
