//
//  Phone+CoreDataProperties.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Phone+CoreDataProperties.h"

@implementation Phone (CoreDataProperties)

+ (NSFetchRequest<Phone *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Phone"];
}

@dynamic createDate;
@dynamic number;
@dynamic company;
@dynamic person;

@end
