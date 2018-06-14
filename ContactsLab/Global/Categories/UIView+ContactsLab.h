//
//  UIView+ContactsLab.h
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
}EdgeOffsets;

typedef NS_OPTIONS(NSInteger, EdgeMask) {
    EdgeMaskTop = 1,
    EdgeMaskRight = (1 << EdgeMaskTop),
    EdgeMaskBottom = (1 << EdgeMaskRight),
    EdgieMaskLeft = (1 << EdgeMaskBottom),
    EdgeMaskHorizontal = EdgieMaskLeft | EdgeMaskRight,
    EdgeMaskVertical = EdgeMaskTop | EdgeMaskBottom,
    EdgeMaskAll = EdgeMaskHorizontal | EdgeMaskVertical
};

EdgeOffsets EdgeOffsetMake(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom);
@interface UIView (ContactsLab)

- (void)pinnView:(UIView*)subview toEdgeOffsets:(EdgeOffsets)offsets;

@end
