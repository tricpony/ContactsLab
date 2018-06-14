//
//  Address+CoreDataProperties.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Address+CoreDataProperties.h"

@implementation Address (CoreDataProperties)

+ (NSFetchRequest<Address *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Address"];
}

@dynamic createDate;
@dynamic street;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic company;
@dynamic person;

@end
