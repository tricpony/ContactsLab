//
//  SearchNavigationController.m
//  ClinicalTrials
//
//  Created by aarthur on 2/11/15.
//  Copyright (c) 2015 Gigabit LLC. All rights reserved.
//

#import "SearchNavigationController.h"
#import "UIColor+ContactsLab.h"

@interface SearchNavigationController ()

@end

@implementation SearchNavigationController

- (NSString*)navBarHexRGBColor
{
    //http://www.blooberry.com/indexdot/color/x11makerFrameNS.htm
    //Khaki
    return @"#F0E68C";
}

- (UIColor*)navBarColor
{
    return [UIColor blackColor];
}

@end
