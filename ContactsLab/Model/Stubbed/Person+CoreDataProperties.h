//
//  Person+CoreDataProperties.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Person+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *firstname;
@property (nullable, nonatomic, copy) NSString *lastname;
@property (nullable, nonatomic, retain) NSSet<Address *> *addresses;
@property (nullable, nonatomic, retain) NSSet<Phone *> *phones;
@property (nullable, nonatomic, copy) Company *company;

@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSSet<Address *> *)values;
- (void)removeAddresses:(NSSet<Address *> *)values;

- (void)addPhonesObject:(Phone *)value;
- (void)removePhonesObject:(Phone *)value;
- (void)addPhones:(NSSet<Phone *> *)values;
- (void)removePhones:(NSSet<Phone *> *)values;

@end

NS_ASSUME_NONNULL_END
