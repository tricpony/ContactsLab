//
//  Phone+CoreDataClass.h
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

@interface Phone : NSManagedObject

+ (Phone*)createPhone:(NSString*)phone context:(NSManagedObjectContext*)ctx;

@end

NS_ASSUME_NONNULL_END

#import "Phone+CoreDataProperties.h"
