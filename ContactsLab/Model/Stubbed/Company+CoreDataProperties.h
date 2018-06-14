//
//  Company+CoreDataProperties.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Company+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Company (CoreDataProperties)

+ (NSFetchRequest<Company *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *owner;
@property (nullable, nonatomic, retain) NSSet<Address *> *addresses;
@property (nullable, nonatomic, retain) NSSet<Phone *> *phones;
@property (nullable, nonatomic, retain) NSSet<Company *> *corpOwners;
@property (nullable, nonatomic, retain) NSSet<Company *> *brands;
@property (nullable, nonatomic, retain) NSSet<Person *> *managers;

@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSSet<Address *> *)values;
- (void)removeAddresses:(NSSet<Address *> *)values;

- (void)addPhonesObject:(Phone *)value;
- (void)removePhonesObject:(Phone *)value;
- (void)addPhones:(NSSet<Phone *> *)values;
- (void)removePhones:(NSSet<Phone *> *)values;

- (void)addCorpOwnersObject:(Company *)value;
- (void)removeCorpOwnersObject:(Company *)value;
- (void)addCorpOwners:(NSSet<Company *> *)values;
- (void)removeCorpOwners:(NSSet<Company *> *)values;

- (void)addBrandsObject:(Company *)value;
- (void)removeBrandsObject:(Company *)value;
- (void)addBrands:(NSSet<Company *> *)values;
- (void)removeBrands:(NSSet<Company *> *)values;

- (void)addManagersObject:(Person *)value;
- (void)removeManagersObject:(Person *)value;
- (void)addManagers:(NSSet<Person *> *)values;
- (void)removeManagers:(NSSet<Person *> *)values;

@end

NS_ASSUME_NONNULL_END
