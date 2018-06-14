//
//  Company+CoreDataClass.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Company+CoreDataClass.h"
#import "CoreDataUtility.h"
#import "Constants.h"

#import "Address+CoreDataClass.h"
#import "Phone+CoreDataClass.h"
#import "Person+CoreDataClass.h"

@implementation Company

+ (Company*)createCompanyWithInfo:(NSDictionary*)info editContext:(NSManagedObjectContext*)ctx
{
    Company *company = nil;
    NSString *name = info[COMPANY_NAME];
    
    if (name) {
        company = [[CoreDataUtility sharedInstance] fetchCompanyNamed:name withEditContext:ctx];
        if (!company) {
            company = [[CoreDataUtility sharedInstance] insertNewCompanyWithEditContext:ctx];
            
            company.name = name;
            [company fillAddressesFrom:info[COMPANY_ADDRESSES] context:ctx];
            [company fillPhonesFrom:info[COMPANY_PHONES] context:ctx];
            [company fillManagersFrom:info[COMPANY_MANAGERS] context:ctx];
            [company fillOwnedBy:info[COMPANY_PARENT]];
        }
        [company fillCompanyBrandsWithContext:ctx];
    }
    
    return company;
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

- (void)fillManagersFrom:(NSArray*)peopleStrings context:(NSManagedObjectContext*)ctx
{
    for (NSString *nextItem in peopleStrings) {
        Person *mgr = nil;
        
        mgr = [Person createPersonNamed:nextItem withContext:ctx];
        if (mgr) {
            [self addManagersObject:mgr];
        }
    }
}

- (void)fillOwnedBy:(NSString*)ownerName
{
    if (ownerName) {
        self.owner = ownerName;
    }
}

- (void)fillCompanyBrandsWithContext:(NSManagedObjectContext*)ctx
{
    NSArray *brands;

    brands = [[CoreDataUtility sharedInstance] fetchCompanyBrandsOwnedBy:self.name withEditContext:ctx];
    for (Company *brand in brands) {
        [self addBrandsObject:brand];
    }
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    //all eos have a create date so set it here
    [self performSelector:@selector(setCreateDate:) withObject:[NSDate date]];
}

@end