//
//  Person+CoreDataProperties.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Person"];
}

@dynamic createDate;
@dynamic firstname;
@dynamic lastname;
@dynamic addresses;
@dynamic phones;
@dynamic company;

@end
