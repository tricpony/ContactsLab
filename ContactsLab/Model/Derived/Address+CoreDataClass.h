//
//  Address+CoreDataClass.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company, Person;

NS_ASSUME_NONNULL_BEGIN

@interface Address : NSManagedObject
@property (readonly, nonatomic) NSDictionary *addressAsDictionary;
@property (readonly, nonatomic) NSDictionary *asGeoCodeDictionary;

+ (Address*)createAddress:(NSString*)address context:(NSManagedObjectContext*)ctx;

@end

NS_ASSUME_NONNULL_END

#import "Address+CoreDataProperties.h"
