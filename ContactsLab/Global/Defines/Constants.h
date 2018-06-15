//
//  Constants.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstantsDefines.h"

/*
 service address
 */
#pragma mark ---- service address ----
extern NSString *SERVICE_ADDRESS;

/*
 service keys
 */
#pragma mark ---- service keys ----
extern NSString *COMPANY_NAME;
extern NSString *COMPANY_PARENT;
extern NSString *COMPANY_MANAGERS;
extern NSString *COMPANY_ADDRESSES;
extern NSString *COMPANY_PHONES;
extern NSString *PERSON_NAME;
extern NSString *PERSON_ADDRESSES;
extern NSString *PERSON_PHONES;

/*
 parse keys
 */
#pragma mark ---- parse keys ----
extern NSString *FIRST;
extern NSString *LAST;

/*
 group type keys
 */
#pragma mark ---- group type keys ----
extern NSString *GROUP_TYPE_KEY;
extern NSString *GROUP_DATA_KEY;
extern NSString *FRC;
extern NSString *STREET_KEY;
extern NSString *CITY_KEY;
extern NSString *STATE_KEY;
extern NSString *ZIP_KEY;

@interface Constants : NSObject

@end
