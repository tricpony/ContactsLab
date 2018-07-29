//
//  NSString+ContactsLab.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "NSString+ContactsLab.h"
#import "Constants.h"

@implementation NSString (ContactsLab)

/**
 Only accepts the operation when [self length] == 7
 Subdivides self into 3 pairs and converts each from hex to base 10
 **/
- (NSMutableArray*)hexAsRGB
{
    NSMutableArray *rgb = nil;
    
    //there must be 3 pairs
    if ([self length] < 7) {
        return nil;
    }
    NSString *redString = nil;
    NSString *greenString = nil;
    NSString *blueString = nil;
    NSRange r;
    char* endPtr = NULL;
    const char* s;
    long l;
    
    rgb = [NSMutableArray arrayWithCapacity:1];
    //parse red component, starting at index 1 to strip off #
    r.location = 1;
    r.length = 2;
    redString = [NSString stringWithFormat:@"0x%@",[self substringWithRange:r]];
    
    //parse blue component
    r.location = 3;
    r.length = 2;
    greenString = [NSString stringWithFormat:@"0x%@",[self substringWithRange:r]];
    
    //green component
    r.location = 5;
    r.length = 2;
    blueString = [NSString stringWithFormat:@"0x%@",[self substringWithRange:r]];
    
    s = [redString UTF8String];
    l = strtol(s, &endPtr, 0);
    if (s != endPtr && *endPtr == '\0') {
        [rgb addObject:@(l)];
    }
    
    endPtr = NULL;
    s = [greenString UTF8String];
    l = strtol(s, &endPtr, 0);
    if (s != endPtr && *endPtr == '\0') {
        [rgb addObject:@(l)];
    }
    
    endPtr = NULL;
    s = [blueString UTF8String];
    l = strtol(s, &endPtr, 0);
    if (s != endPtr && *endPtr == '\0') {
        [rgb addObject:@(l)];
    }
    return rgb;
}

/**
 trims both ends
 **/
- (NSString*)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSAttributedString*)attributedStringHighlightingRange:(NSRange)range color:(UIColor*)highLightColor
{
    NSMutableAttributedString *attributedString;
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    
    if (highLightColor && range.location != NSNotFound) {
        [attributedString addAttribute:NSBackgroundColorAttributeName value:highLightColor range:range];
    }
    return attributedString;
}

- (NSDictionary*)parseFirstAndLastName
{
    if ([self rangeOfString:@" "].location == NSNotFound) return nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b[a-z]+\\b"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:NULL];
    
    NSMutableDictionary *parsedName = nil;
    NSInteger i = 0;
    NSArray *matches = [regex matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange r = [match rangeAtIndex:0];
        NSString *key = FIRST;
        NSString *nameSeg = nil;
        
        if (!parsedName) {
            parsedName = [NSMutableDictionary dictionaryWithCapacity:2];
        }
        if (i == 1) {
            key = LAST;
        }
        
        nameSeg = [self substringWithRange:r];
        parsedName[key] = nameSeg;
        ++i;
    }
    return parsedName;
}

- (BOOL)startsWithString:(NSString*)starting
{
    NSUInteger i = [starting length];
    return i < [self length] && [[self substringToIndex:i] isEqualToString:starting];
}

@end
