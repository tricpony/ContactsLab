//
//  UIView+ContactsLab.m
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "UIView+ContactsLab.h"

EdgeOffsets EdgeOffsetMake(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom)
{
    EdgeOffsets offsets;
    
    offsets.left = left;
    offsets.top = top;
    offsets.right = right;
    offsets.bottom = bottom;
    
    return offsets;
}

@implementation UIView (ContactsLab)

- (void)pinnView:(UIView*)subview toEdgeOffsets:(EdgeOffsets)offsets
{
    NSArray *constraints;
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftGap)-[subview]-(rightGap)-|"
                                                          options:0
                                                          metrics:@{@"leftGap":@(offsets.left),@"rightGap":@(offsets.right)}
                                                            views:@{@"subview":subview}];
    [self addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topGap)-[subview]-(bottomGap)-|"
                                                          options:0
                                                          metrics:@{@"topGap":@(offsets.left),@"bottomGap":@(offsets.right)}
                                                            views:@{@"subview":subview}];
    [self addConstraints:constraints];
}

@end
