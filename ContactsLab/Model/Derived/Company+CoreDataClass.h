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

+ (Company*)createCompanyWithInfo:(NSDictionary*)info editContext:(NSManagedObjectContext*)ctx;
- (void)fillCompanyBrandsWithContext:(NSManagedObjectContext*)ctx;
- (NSString*)searchTerm;
- (NSString*)displayName;

@end

NS_ASSUME_NONNULL_END

#import "Company+CoreDataProperties.h"
