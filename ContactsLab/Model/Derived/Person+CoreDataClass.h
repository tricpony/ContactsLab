//
//  Person+CoreDataClass.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Phone, Company;

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSManagedObject
@property (readonly, nonatomic) NSString *fullname;
@property (readonly, nonatomic) NSString *displayName;

+ (Person*)createPersonNamed:(NSString*)name withContext:(NSManagedObjectContext*)ctx;
- (void)fillAddressesFrom:(NSArray*)addressStrings context:(NSManagedObjectContext*)ctx;
- (void)fillPhonesFrom:(NSArray*)phoneStrings context:(NSManagedObjectContext*)ctx;

@end

NS_ASSUME_NONNULL_END

#import "Person+CoreDataProperties.h"
