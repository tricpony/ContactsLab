//
//  Address+CoreDataClass.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Address+CoreDataClass.h"
#import "CoreDataUtility.h"
#import "NSString+ContactsLab.h"
#import <Contacts/Contacts.h>
#import "Constants.h"

#define STREET @"street"
#define CITY @"city"
#define STATE @"state"
#define ZIP @"zip"

@implementation Address

+ (NSDictionary*)parseAddress:(NSString*)address
{
    NSString *delimeter = @",";
    NSMutableDictionary *parsedAddress;
    NSArray *addressKeys = @[STREET,CITY,STATE,ZIP];
    NSInteger lastLocation = 0;
    NSString *subAddress = [address copy];

    for (NSString *nextAddressKey in addressKeys) {
        NSRange r;
        NSString *addressValue = nil;

        subAddress = [subAddress substringFromIndex:lastLocation];
        if ([STATE isEqualToString:nextAddressKey]) {
            subAddress = [subAddress trim];
            delimeter = @" ";
        }else if ([ZIP isEqualToString:nextAddressKey] && [subAddress length]) {
            parsedAddress[nextAddressKey] = subAddress;
            break;
        }
        r = [subAddress rangeOfString:delimeter];
        if (r.location != NSNotFound) {
            
            if (!parsedAddress) {
                parsedAddress = [NSMutableDictionary dictionaryWithCapacity:4];
            }
            addressValue = [subAddress substringToIndex:r.location];
            addressValue = [addressValue trim];
            parsedAddress[nextAddressKey] = addressValue;
            lastLocation = r.location+1;
        }else{
            if ([STATE isEqualToString:nextAddressKey] && [subAddress length]) {
                parsedAddress[nextAddressKey] = subAddress;
            }
            break;
        }
    }
    
    return parsedAddress;
}

+ (Address*)createAddress:(NSString*)address context:(NSManagedObjectContext*)ctx
{
    Address *addressObj;
    NSDictionary *addressInfo;
    
    addressInfo = [self parseAddress:address];
    addressObj = [[CoreDataUtility sharedInstance] fetchAddressMatchingStreet:addressInfo[STREET] zip:addressInfo[ZIP] withEditContext:ctx];
    
    if (!addressObj) {
        addressObj = [[CoreDataUtility sharedInstance] insertNewAddressWithEditContext:ctx];
        addressObj.street = addressInfo[STREET];
        addressObj.city = addressInfo[CITY];
        addressObj.state = addressInfo[STATE];
        addressObj.zip = addressInfo[ZIP];
    }
    
    return addressObj;
}

- (NSDictionary*)addressAsDictionary
{
    NSMutableDictionary *addressInfo = [NSMutableDictionary dictionaryWithCapacity:4];
            
    if (self.street) {
        addressInfo[STREET_KEY] = self.street;
    }
    if (self.city) {
        addressInfo[CITY_KEY] = self.city;
    }
    if (self.state) {
        addressInfo[STATE_KEY] = self.state;
    }
    if (self.zip) {
        addressInfo[ZIP_KEY] = self.zip;
    }
    
    return addressInfo;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    //all eos have a create date so set it here
    [self performSelector:@selector(setCreateDate:) withObject:[NSDate date]];
}

- (NSDictionary*)asGeoCodeDictionary
{
    NSMutableDictionary *geoDict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (self.street) {
        geoDict[CNPostalAddressStreetKey] = self.street;
    }
    if (self.zip) {
        geoDict[CNPostalAddressPostalCodeKey] = self.zip;
    }
    if (self.city) {
        geoDict[CNPostalAddressCityKey] = self.city;
    }
    
    return [NSDictionary dictionaryWithDictionary:geoDict];
}

@end
