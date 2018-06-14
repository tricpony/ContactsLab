//
//  NSString+ContactsLab.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "NSString+ContactsLab.h"

@implementation NSString (ContactsLab)

/**
 trims both ends
 **/
- (NSString*)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
