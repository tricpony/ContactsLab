//
//  Person+CoreDataClass.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Person+CoreDataClass.h"
#import "CoreDataUtility.h"

#import "Address+CoreDataClass.h"
#import "Phone+CoreDataClass.h"

#define FIRST @"first"
#define LAST @"last"

@implementation Person

/**
 Instead of using componentsSeparatedByString, which would fail if the delimiter did not exactly match
 Going with brute force regEx
 This way, no matter how many spaces separate first & last names, it should work
 **/
+ (NSDictionary*)parseFirstAndLastOfName:(NSString*)name
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b[a-z]+\\b"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:NULL];

    NSMutableDictionary *parsedName = nil;
    NSInteger i = 0;
    NSArray *matches = [regex matchesInString:name
                                      options:0
                                        range:NSMakeRange(0, [name length])];
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
        
        nameSeg = [name substringWithRange:r];
        parsedName[key] = nameSeg;
        ++i;
    }
    return parsedName;
}

+ (Person*)createPersonNamed:(NSString*)name withContext:(NSManagedObjectContext*)ctx
{
    Person *person;
    NSDictionary *names;
    NSString *firstname;
    NSString *lastname;
    
    names = [self parseFirstAndLastOfName:name];
    firstname = names[FIRST];
    lastname = names[LAST];
    person = [[CoreDataUtility sharedInstance] fetchPersonNamed:firstname lastname:lastname withEditContext:ctx];
    if (!person) {
        person = [[CoreDataUtility sharedInstance] insertNewPersonWithEditContext:ctx];
        person.firstname = firstname;
        person.lastname = lastname;
    }
    
    return person;
}

- (void)fillAddressesFrom:(NSArray*)addressStrings context:(NSManagedObjectContext*)ctx
{
    for (NSString *nextItem in addressStrings) {
        Address *address = nil;
        
        address = [Address createAddress:nextItem context:ctx];
        if (address) {
            [self addAddressesObject:address];
        }
    }
}

- (void)fillPhonesFrom:(NSArray*)phoneStrings context:(NSManagedObjectContext*)ctx
{
    for (NSString *nextItem in phoneStrings) {
        Phone *phone = nil;
        
        phone = [Phone createPhone:nextItem context:ctx];
        if (phone) {
            [self addPhonesObject:phone];
        }
    }
}

- (NSString*)fullname
{
    if (self.firstname && self.lastname) {
        return [NSString stringWithFormat:@"%@ %@",self.firstname,self.lastname];
    }
    
    return @"";
}

- (NSString*)displayName
{
    return self.fullname;
}

- (NSString*)searchTerm
{
    return self.fullname;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    //all eos have a create date so set it here
    [self performSelector:@selector(setCreateDate:) withObject:[NSDate date]];
}

@end
