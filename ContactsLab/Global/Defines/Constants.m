//
//  Constants.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "Constants.h"

/*
 web service address
 */
#pragma mark ---- service address ----
NSString *SERVICE_ADDRESS = @"https://api.myjson.com/bins/jz6bp";

/*
 service keys
 */
#pragma mark ---- service keys ----
NSString *COMPANY_NAME = @"companyName";
NSString *COMPANY_PARENT = @"parent";
NSString *COMPANY_MANAGERS = @"managers";
NSString *COMPANY_ADDRESSES = @"addresses";
NSString *COMPANY_PHONES = @"phones";
NSString *PERSON_NAME = @"name";
NSString *PERSON_ADDRESSES = @"addresses";
NSString *PERSON_PHONES = @"phones";

/*
 parse keys
 */
#pragma mark ---- parse keys ----
NSString *FIRST = @"first";
NSString *LAST = @"last";

/*
 group type keys
 */
#pragma mark ---- group type keys ----
NSString *GROUP_TYPE_KEY = @"groupType";
NSString *GROUP_DATA_KEY = @"groupData";
NSString *FRC = @"fetchResultsController";
NSString *STREET_KEY = @"STREET_KEY";
NSString *CITY_KEY = @"CITY_KEY";
NSString *STATE_KEY = @"STATE_KEY";
NSString *ZIP_KEY = @"ZIP_KEY";

@implementation Constants

@end
