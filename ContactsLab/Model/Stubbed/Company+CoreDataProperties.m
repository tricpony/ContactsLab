//
//  Company+CoreDataProperties.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Company+CoreDataProperties.h"

@implementation Company (CoreDataProperties)

+ (NSFetchRequest<Company *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Company"];
}

@dynamic createDate;
@dynamic name;
@dynamic owner;
@dynamic addresses;
@dynamic phones;
@dynamic corpOwners;
@dynamic brands;
@dynamic managers;

@end
