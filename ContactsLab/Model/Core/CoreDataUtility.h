//
//  CoreDataUtility.h
//  ClinincalTrials
//
//  Created by aarthur on 12/17/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company;
@class Person;
@class Phone;
@class Address;
@interface CoreDataUtility : NSObject

+ (CoreDataUtility*)sharedInstance;

/**
 Fetch Requests
 **/
- (NSFetchRequest*)fetchRequestForCompanyContainingSearchTerm:(NSString*)searchTerm withEditContext:(NSManagedObjectContext*)ctx;
- (NSFetchRequest*)fetchRequestForPersonContainingSearchTerm:(NSString*)searchTerm withEditContext:(NSManagedObjectContext*)ctx;
- (NSFetchRequest*)fetchRequestForBrandsWithEditContext:(NSManagedObjectContext*)ctx;

/**
 Fetching
 **/
- (Company*)fetchCompanyNamed:(NSString*)name withEditContext:(NSManagedObjectContext*)ctx;
- (Company*)fetchCompanyWithOwnerName:(NSString*)ownerName withEditContext:(NSManagedObjectContext*)ctx;
- (NSArray*)fetchCompanyBrandsOwnedBy:(NSString*)ownerName withEditContext:(NSManagedObjectContext*)ctx;
- (NSArray*)fetchAllCompaniesWithContext:(NSManagedObjectContext*)ctx;

- (Address*)fetchAddressMatchingStreet:(NSString*)street zip:(NSString*)zip withEditContext:(NSManagedObjectContext*)ctx;
- (Person*)fetchPersonNamed:(NSString*)firstname lastname:(NSString*)lastname withEditContext:(NSManagedObjectContext*)ctx;
- (Phone*)fetchPhoneMatchingNumber:(NSString*)number withEditContext:(NSManagedObjectContext*)ctx;

/**
 Inserting
 **/
- (id)insertNewEONamed:(NSString*)entityName editContext:(NSManagedObjectContext*)ctx;
- (id)insertNewCompanyWithEditContext:(NSManagedObjectContext*)ctx;
- (id)insertNewPersonWithEditContext:(NSManagedObjectContext*)ctx;
- (id)insertNewPhoneWithEditContext:(NSManagedObjectContext*)ctx;
- (id)insertNewAddressWithEditContext:(NSManagedObjectContext*)ctx;

/**
 Saving
 **/
- (void)persistContext:(NSManagedObjectContext *)context wait:(BOOL)wait;

/**
 Pre-fabbed predicates
 **/
- (NSPredicate*)equalToPredicateForKey:(NSString*)key andValue:(id)value caseInsensitive:(BOOL)yesNo;
- (NSPredicate*)equalToAnyPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)equalToAllPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)equalToPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)notEqualToPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)greaterThanPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)greaterThanOrEqualToPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)lessThanPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)lessThanOrEqualToPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)beginsWithPredicateForKey:(NSString*)key andValue:(id)value caseInsensitive:(BOOL)yesNo;
- (NSPredicate*)beginsWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)endsWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)likeWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)containsWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)containsAnyWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)matchesWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)likeAnyWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)likeAllWithPredicateForKey:(NSString*)key andValue:(id)value;
- (NSPredicate*)inWithPredicateForKey:(NSString*)key andValues:(NSArray*)values;
- (NSPredicate*)inAnyWithPredicateForKey:(NSString*)key andValues:(NSArray*)values;
- (NSPredicate*)notInWithPredicateForKey:(NSString*)key andValues:(NSArray*)values;

@end
