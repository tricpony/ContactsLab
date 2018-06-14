//
//  Phone+CoreDataProperties.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Phone+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Phone (CoreDataProperties)

+ (NSFetchRequest<Phone *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *number;
@property (nullable, nonatomic, retain) Company *company;
@property (nullable, nonatomic, retain) Person *person;

@end

NS_ASSUME_NONNULL_END
