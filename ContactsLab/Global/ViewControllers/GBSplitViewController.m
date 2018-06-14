//
//  GBSplitViewController.m
//  ClinicalTrials
//
//  Created by aarthur on 5/19/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import "GBSplitViewController.h"
#import "Constants.h"

@interface GBSplitViewController () <UISplitViewControllerDelegate,UITabBarControllerDelegate>

@property (weak, nonatomic) id <UISplitViewControllerDelegate, NSObject> forwardDelegate;
@property (assign, nonatomic) BOOL navigationIsInMoreTab;

@end

@implementation GBSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.tabBarController.delegate = self;
}

- (void)assignNextActiveForwardDelegate:(id <UISplitViewControllerDelegate,NSObject>)object
{
    self.forwardDelegate = object;
}

- (UITabBarController*)tabBarController
{
    UITabBarController *tabBarController = [self.viewControllers firstObject];
    
    if ([tabBarController isKindOfClass:[UITabBarController class]]) {
        return tabBarController;
    }

    return nil;
}

- (void)showInitialDetailViewControllerForPrimary:(UIViewController <GBDetailViewControllerCoordination> *)primaryVC
{
    UIUserInterfaceSizeClass hSizeClass = self.traitCollection.horizontalSizeClass;
    
    //if we are horizontally compact, do nothing
    if (hSizeClass == UIUserInterfaceSizeClassCompact) {
        return;
    }
    UIStoryboard *sb;
    UIViewController * vc;
    
    sb = [UIStoryboard storyboardWithName:@"Detail" bundle:nil];
    vc = [sb instantiateViewControllerWithIdentifier:primaryVC.storyboardIDForPlaceholderScene];
    [self showDetailViewController:vc sender:primaryVC];
}

#pragma mark UITabBarControllerDelegate

/**
 We need to know if navigation is in the more tab to guide logic in showDetailViewController below
 **/
- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
    BOOL isMoreTab = NO;
    Class saveNavClass = NSClassFromString(@"SavedNavigationController");
    
    if (tabBarController.moreNavigationController == viewController) {
        isMoreTab = YES;
    }
    if ([viewController isKindOfClass:saveNavClass]) {
        isMoreTab = YES;
    }
        
    self.navigationIsInMoreTab = isMoreTab;
}

#pragma mark UISplitViewControllerDelegate

- (UIViewController*)primaryViewControllerForExpandingSplitViewController:(UISplitViewController*)splitViewController
{
    return nil;
}

- (BOOL)splitViewController:(UISplitViewController*)splitViewController showDetailViewController:(UIViewController*)vc sender:(id)sender
{
    if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        UITabBarController *tabVC = self.viewControllers.firstObject;
        UINavigationController *navigationVC = tabVC.selectedViewController;
        UINavigationController *navVC = (id)vc;
        UIViewController *presentedVC = navVC.viewControllers.firstObject;
        
        if (self.navigationIsInMoreTab) {
            navigationVC = tabVC.moreNavigationController;
        }
        
        //the logic in this if block AMAZINGLY keeps the tab bar on screen when navigating to detail screens
        [navigationVC pushViewController:presentedVC animated:YES];
        return YES;
    }
    
    return NO;
}

/**
 This delegate method is only called for iPhone plus, no others, dunno why
 **/
- (UIViewController*)splitViewController:(UISplitViewController*)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController*)primaryViewController
{
    //this is a trick I learned from:
    //http://stackoverflow.com/questions/37578425/iphone-6-plus-uisplitviewcontroller-crash-with-recursive-canbecomedeepestunambi
    //
    //the iphone plus will crash on landscape rotation without this code, other size classes work fine w/out this assist
    if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        UITabBarController *tabVC = self.viewControllers.firstObject;
        UINavigationController *masterNavController = tabVC.selectedViewController;
        UIStoryboard *sb = self.storyboard;
        UINavigationController *detailNavController;
        UIViewController *presentedVC;
        
        detailNavController = [sb instantiateViewControllerWithIdentifier:@"DetailNavStackScene"];
        presentedVC = [masterNavController popViewControllerAnimated:NO];
        
        if (!presentedVC) {
            sb = [UIStoryboard storyboardWithName:@"Detail" bundle:nil];
            presentedVC = [(UINavigationController*)[sb instantiateInitialViewController] viewControllers].firstObject;
        }
        detailNavController.viewControllers = @[presentedVC];

        return detailNavController;
    }
    
    return nil;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        return [self.forwardDelegate splitViewController:splitViewController collapseSecondaryViewController:secondaryViewController
                               ontoPrimaryViewController:primaryViewController];
    }
    
    return NO;
}

@end
