//
//  UIColor+ContactsLab.h
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ContactsLab)

+ (UIColor*)GBBlue;
+ (UIColor*)teal;
+ (UIColor*)colorForHexRGB:(NSString*)rgbHexString withAlpha:(CGFloat)alpha;
+ (UIColor*)colorForHexRGB:(NSString*)rgbHexString;

@end
