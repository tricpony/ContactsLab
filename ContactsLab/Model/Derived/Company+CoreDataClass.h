//
//  Company+CoreDataClass.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Person, Phone;

NS_ASSUME_NONNULL_BEGIN

@interface Company : NSManagedObject
@property (readonly, nonatomic) NSString *displayName;
@property (readonly, nonatomic) BOOL isCorpOwner;
@property (readonly, nonatomic) BOOL hasCorpOwners;
@property (readonly, nonatomic) BOOL hasBrands;
@property (readonly, nonatomic) BOOL hasManagers;
@property (readonly, nonatomic) BOOL hasAddresses;
@property (readonly, nonatomic) BOOL hasPhones;
@property (readonly, nonatomic) NSArray *addressesAsDictionaries;

+ (Company*)createCompanyWithInfo:(NSDictionary*)info editContext:(NSManagedObjectContext*)ctx;
- (void)fillCompanyBrandsWithContext:(NSManagedObjectContext*)ctx;
- (NSString*)searchTerm;

@end

NS_ASSUME_NONNULL_END

#import "Company+CoreDataProperties.h"
