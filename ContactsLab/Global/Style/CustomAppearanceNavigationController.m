//
//  CustomAppearanceNavigationController.m
//  ClinicalTrials
//
//  Created by aarthur on 2/12/15.
//  Copyright (c) 2015 Gigabit LLC. All rights reserved.
//

#import "CustomAppearanceNavigationController.h"
#import "UIColor+ContactsLab.h"

@implementation CustomAppearanceNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:self.navBarColor];
}

- (NSString*)navBarHexRGBColor
{
    return @"#F5F5DC";  //defaults to beige
}

- (UIColor*)navBarColor
{
    return [UIColor colorForHexRGB:self.navBarHexRGBColor];
}

@end
