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
#import "Constants.h"

#import "Company+CoreDataClass.h"
#import "Address+CoreDataClass.h"
#import "Phone+CoreDataClass.h"
#import "NSString+ContactsLab.h"

@implementation Person

/**
 Instead of using componentsSeparatedByString, which would fail if the delimiter did not exactly match
 Going with brute force regEx
 This way, no matter how many spaces separate first & last names, it should work
 **/
+ (NSDictionary*)parseFirstAndLastOfName:(NSString*)name
{
    return [name parseFirstAndLastName];
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
