//
//  UIColor+ContactsLab.m
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "UIColor+ContactsLab.h"
#import "NSString+ContactsLab.h"

@implementation UIColor (ContactsLab)

+ (UIColor*)GBBlue
{
    return [UIColor colorWithRed:65/255.f green:122/255.f blue:160/255.f alpha:1.0];
}

/**
 http://www.blooberry.com/indexdot/color/x11makerFrameNS.htm
 **/
+ (UIColor*)teal
{
    return [UIColor colorForHexRGB:@"#008080"];
}

+ (UIColor*)colorForHexRGB:(NSString*)rgbHexString withAlpha:(CGFloat)alpha
{
    NSArray *rgb = nil;
    CGFloat red,green,blue;
    UIColor *aColor = nil;
    CGFloat denom = 255.0;
    
    rgb = [rgbHexString hexAsRGB];
    
    if (rgb) {
        
        //we want the color as a percent, so divide by 255.0
        red = ((CGFloat)[rgb[0] longValue])/denom;
        green = ((CGFloat)[rgb[1] longValue])/denom;
        blue = ((CGFloat)[rgb[2] longValue])/denom;
        aColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    return aColor;
}

+ (UIColor*)colorForHexRGB:(NSString*)rgbHexString
{
    return [self colorForHexRGB:rgbHexString withAlpha:1.0];
}

@end
