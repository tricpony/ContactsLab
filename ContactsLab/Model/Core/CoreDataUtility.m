//
//  CoreDataUtility.m
//  ClinincalTrials
//
//  Created by aarthur on 12/17/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "CoreDataUtility.h"
#import "Constants.h"

#import "Address+CoreDataClass.h"
#import "Company+CoreDataClass.h"
#import "Person+CoreDataClass.h"
#import "Phone+CoreDataClass.h"
#import "NSString+ContactsLab.h"

static CoreDataUtility *sharedInstance = nil;

@implementation CoreDataUtility

#pragma mark
#pragma mark ---- data base operations ----
#pragma mark ---- Fetching Requests ----

- (NSFetchRequest*)fetchRequestForEntityNamed:(NSString*)entityName withEditContext:(NSManagedObjectContext*)ctx predicate:(NSPredicate*)q sortDescriptors:(NSArray*)sortOrders
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:ctx];
    
    [request setEntity:entity];
    
    if (q) {
        [request setPredicate:q];
    }
    
    if (sortOrders) {
        [request setSortDescriptors:sortOrders];
    }
    
    return request;
    
}

- (NSFetchRequest*)fetchRequestForCompanyContainingSearchTerm:(NSString*)searchTerm withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    NSFetchRequest *request;
    NSSortDescriptor *descriptor;
    
    descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    q = [self containsWithPredicateForKey:@"name" andValue:searchTerm];
    request = [self fetchRequestForEntityNamed:@"Company" withEditContext:ctx predicate:q sortDescriptors:@[descriptor]];
    
    return request;
}

- (NSFetchRequest*)fetchRequestForPersonContainingSearchTerm:(NSString*)searchTerm withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    NSPredicate *lq;
    NSFetchRequest *request;
    NSSortDescriptor *descriptor;
    
    descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastname" ascending:YES];
    q = [self containsWithPredicateForKey:@"firstname" andValue:searchTerm];
    lq = [self containsWithPredicateForKey:@"lastname" andValue:searchTerm];
    q = [NSCompoundPredicate orPredicateWithSubpredicates:@[q,lq]];
    request = [self fetchRequestForEntityNamed:@"Person" withEditContext:ctx predicate:q sortDescriptors:@[descriptor]];
    
    return request;
}

- (NSFetchRequest*)fetchRequestForBrandsWithEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    NSFetchRequest *request;
    NSSortDescriptor *descriptor;
    
    descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    q = [NSPredicate predicateWithFormat:@"corpOwners.@count == 1"];
    request = [self fetchRequestForEntityNamed:@"Company" withEditContext:ctx predicate:q sortDescriptors:@[descriptor]];
    
    return request;
}

#pragma mark
#pragma mark ---- Fetching EOS ----

- (NSArray*)fetchEntityNamed:(NSString*)entityName withEditContext:(NSManagedObjectContext*)ctx predicate:(NSPredicate*)q sortDescriptors:(NSArray*)sortOrders
{
    __block NSArray *results;
    
    [ctx performBlockAndWait:^{
        {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSError *error = nil;
            NSEntityDescription *entity = nil;
            
            entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:ctx];
            [request setEntity:entity];
            
            if (q) {
                [request setPredicate:q];
            }
            
            if (sortOrders) {
                [request setSortDescriptors:sortOrders];
            }
            
            results = [ctx executeFetchRequest:request error:&error];
        }
    }];
    
    return results;
    
}

- (NSArray*)fetchEntityNamed:(NSString*)entityName withEditContext:(NSManagedObjectContext*)ctx predicate:(NSPredicate*)q
{
    return [self fetchEntityNamed:entityName withEditContext:ctx predicate:q sortDescriptors:nil];
}

- (Company*)fetchCompanyNamed:(NSString*)name withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    
    q = [self equalToPredicateForKey:@"name" andValue:name];
    return [[self fetchEntityNamed:@"Company" withEditContext:ctx predicate:q] lastObject];
}

- (Company*)fetchCompanyWithOwnerName:(NSString*)ownerName withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    
    q = [self equalToPredicateForKey:@"owner" andValue:ownerName];
    return [[self fetchEntityNamed:@"Company" withEditContext:ctx predicate:q] lastObject];
}

- (NSArray*)fetchCompanyBrandsOwnedBy:(NSString*)ownerName withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    
    q = [self equalToPredicateForKey:@"owner" andValue:ownerName];
    return [self fetchEntityNamed:@"Company" withEditContext:ctx predicate:q];
}

- (NSArray*)fetchAllCompaniesWithContext:(NSManagedObjectContext*)ctx
{
    return [self fetchEntityNamed:@"Company" withEditContext:ctx predicate:nil];
}

- (Address*)fetchAddressMatchingStreet:(NSString*)street zip:(NSString*)zip withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    NSPredicate *lq;
    
    q = [self equalToPredicateForKey:@"street" andValue:street];
    lq = [self equalToPredicateForKey:@"zip" andValue:zip];
    q = [NSCompoundPredicate andPredicateWithSubpredicates:@[q,lq]];
    return [[self fetchEntityNamed:@"Address" withEditContext:ctx predicate:q] lastObject];
}

- (Person*)fetchPersonNamed:(NSString*)firstname lastname:(NSString*)lastname withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    NSPredicate *lq;

    q = [self equalToPredicateForKey:@"firstname" andValue:firstname];
    lq = [self equalToPredicateForKey:@"lastname" andValue:lastname];
    q = [NSCompoundPredicate andPredicateWithSubpredicates:@[q,lq]];
    return [[self fetchEntityNamed:@"Person" withEditContext:ctx predicate:q] lastObject];
}

- (Phone*)fetchPhoneMatchingNumber:(NSString*)number withEditContext:(NSManagedObjectContext*)ctx
{
    NSPredicate *q;
    
    q = [self equalToPredicateForKey:@"number" andValue:number];
    return [[self fetchEntityNamed:@"Phone" withEditContext:ctx predicate:q] lastObject];
}

#pragma mark ---- New EOS ----

- (id)insertNewEONamed:(NSString*)entityName editContext:(NSManagedObjectContext*)ctx
{
    __block id newEO = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:ctx];
    
    [ctx performBlockAndWait:^{
        newEO = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:ctx];
    }];
    return newEO;
}

- (id)insertNewCompanyWithEditContext:(NSManagedObjectContext*)ctx
{
    return [self insertNewEONamed:@"Company" editContext:ctx];
}

- (id)insertNewPersonWithEditContext:(NSManagedObjectContext*)ctx
{
    return [self insertNewEONamed:@"Person" editContext:ctx];
}

- (id)insertNewPhoneWithEditContext:(NSManagedObjectContext*)ctx
{
    return [self insertNewEONamed:@"Phone" editContext:ctx];
}

- (id)insertNewAddressWithEditContext:(NSManagedObjectContext*)ctx
{
    return [self insertNewEONamed:@"Address" editContext:ctx];
}

#pragma mark
#pragma mark ---- Save Methods ----

- (void)persistContext:(NSManagedObjectContext *)context wait:(BOOL)wait
{
    __weak __typeof(self)weakSelf = self;
    
    if (wait) {
        [context performBlockAndWait:^{
            [context save:NULL];
            if (context.parentContext) {
                NSManagedObjectContext *parent = context.parentContext;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [strongSelf persistContext:parent wait:wait];
                });
            }
        }];
    }else{
        [context performBlock:^{
            [context save:NULL];
            if (context.parentContext) {
                NSManagedObjectContext *parent = context.parentContext;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [strongSelf persistContext:parent wait:wait];
                });
            }
        }];
    }
}

#pragma mark
#pragma mark ---- Pre-fabbed predicates ----

- (NSPredicate*)equalToPredicateForKey:(NSString*)key andValue:(id)value caseInsensitive:(BOOL)yesNo
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = nil;
	
	if (yesNo) {
		q = [NSComparisonPredicate
			 predicateWithLeftExpression:lhs
			 rightExpression:rhs
			 modifier:NSDirectPredicateModifier
			 type:NSEqualToPredicateOperatorType
			 options:NSCaseInsensitivePredicateOption];
	}else{
		q = [NSComparisonPredicate
			 predicateWithLeftExpression:lhs
			 rightExpression:rhs
			 modifier:NSDirectPredicateModifier
			 type:NSEqualToPredicateOperatorType
			 options:0];
	}
	
	return q;
}

- (NSPredicate*)equalToPredicateForKey:(NSString*)key andValue:(id)value
{
	return [self equalToPredicateForKey:key andValue:value caseInsensitive:NO];
}

- (NSPredicate*)equalToAnyPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSAnyPredicateModifier
					  type:NSEqualToPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)equalToAllPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSAllPredicateModifier
					  type:NSEqualToPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)notEqualToPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSNotEqualToPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)greaterThanPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSGreaterThanPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)greaterThanOrEqualToPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSGreaterThanOrEqualToPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)lessThanPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSLessThanPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)lessThanOrEqualToPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSLessThanOrEqualToPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)beginsWithPredicateForKey:(NSString*)key andValue:(id)value caseInsensitive:(BOOL)yesNo
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = nil;
    
    if (yesNo) {
        q = [NSComparisonPredicate
             predicateWithLeftExpression:lhs
             rightExpression:rhs
             modifier:NSDirectPredicateModifier
             type:NSBeginsWithPredicateOperatorType
             options:NSCaseInsensitivePredicateOption];
    }else{
        q = [NSComparisonPredicate
             predicateWithLeftExpression:lhs
             rightExpression:rhs
             modifier:NSDirectPredicateModifier
             type:NSBeginsWithPredicateOperatorType
             options:0];
    }
	return q;
}

- (NSPredicate*)beginsWithPredicateForKey:(NSString*)key andValue:(id)value
{
	return [self beginsWithPredicateForKey:key andValue:value caseInsensitive:NO];
}

- (NSPredicate*)endsWithPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSEndsWithPredicateOperatorType
					  options:0];
	return q;
}

- (NSPredicate*)likeWithPredicateForKey:(NSString*)key andValue:(id)value
{
    NSExpression *lhs = [NSExpression expressionForKeyPath:key];
    NSExpression *rhs = [NSExpression expressionForConstantValue:value];
    NSPredicate *q = [NSComparisonPredicate
                      predicateWithLeftExpression:lhs
                      rightExpression:rhs
                      modifier:NSDirectPredicateModifier
                      type:NSLikePredicateOperatorType
                      options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];
    
    return q;
}

- (NSPredicate*)containsWithPredicateForKey:(NSString*)key andValue:(id)value
{
    NSExpression *lhs = [NSExpression expressionForKeyPath:key];
    NSExpression *rhs = [NSExpression expressionForConstantValue:value];
    NSPredicate *q = [NSComparisonPredicate
                      predicateWithLeftExpression:lhs
                      rightExpression:rhs
                      modifier:NSDirectPredicateModifier
                      type:NSContainsPredicateOperatorType
                      options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];
    
    return q;
}

- (NSPredicate*)containsAnyWithPredicateForKey:(NSString*)key andValue:(id)value
{
    NSExpression *lhs = [NSExpression expressionForKeyPath:key];
    NSExpression *rhs = [NSExpression expressionForConstantValue:value];
    NSPredicate *q = [NSComparisonPredicate
                      predicateWithLeftExpression:lhs
                      rightExpression:rhs
                      modifier:NSAnyPredicateModifier | NSDirectPredicateModifier
                      type:NSContainsPredicateOperatorType
                      options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];
    
    return q;
}

- (NSPredicate*)matchesWithPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSDirectPredicateModifier
					  type:NSMatchesPredicateOperatorType
					  options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];
    
	return q;
}

/**
 A predicate to match with any entry in the destination of a to-many relationship.
 The left hand side must be a collection. The corresponding predicate compares each
 value in the left hand side against the right hand side and returns YES when it
 finds the first match—or NO if no match is found
 **/
- (NSPredicate*)likeAnyWithPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSAnyPredicateModifier
					  type:NSLikePredicateOperatorType
					  options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];
	return q;
}

/**
 A predicate to compare all entries in the destination of a to-many relationship.
 The left hand side must be a collection. The corresponding predicate compares each
 value in the left hand side with the right hand side, and returns NO when it
 finds the first mismatch—or YES if all match.
 **/
- (NSPredicate*)likeAllWithPredicateForKey:(NSString*)key andValue:(id)value
{
	NSExpression *lhs = [NSExpression expressionForKeyPath:key];
	NSExpression *rhs = [NSExpression expressionForConstantValue:value];
	NSPredicate *q = [NSComparisonPredicate
					  predicateWithLeftExpression:lhs
					  rightExpression:rhs
					  modifier:NSAllPredicateModifier
					  type:NSLikePredicateOperatorType
					  options:NSCaseInsensitivePredicateOption];
	return q;
}

- (NSPredicate*)inWithPredicateForKey:(NSString*)key andValues:(NSArray*)values
{
	return [NSPredicate predicateWithFormat: @"(%K IN %@)", key, values];
}

- (NSPredicate*)inAnyWithPredicateForKey:(NSString*)key andValues:(NSArray*)values
{
	return [NSPredicate predicateWithFormat: @"(ANY %K IN %@)", key, values];
}

- (NSPredicate*)notInWithPredicateForKey:(NSString*)key andValues:(NSArray*)values
{
	NSPredicate *subQ = nil;
	
	subQ = [self inWithPredicateForKey:key andValues:values];
	subQ = [NSCompoundPredicate notPredicateWithSubpredicate:subQ];
	
	return subQ;
}

#pragma mark ---- singleton object methods ----

- (id) init {
	self = [super init];
	if (self != nil) {
        
	}
	return self;
}

// See "Creating a Singleton Instance" in the Cocoa Fundamentals Guide for more info
+ (CoreDataUtility*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            id localSelf;
            
            localSelf = [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

@end
