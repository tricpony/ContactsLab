//
//  NSString+ContactsLab.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (ContactsLab)

- (NSMutableArray*)hexAsRGB;
- (NSString*)trim;
- (NSAttributedString*)attributedStringHighlightingRange:(NSRange)range color:(UIColor*)highLightColor;

@end
