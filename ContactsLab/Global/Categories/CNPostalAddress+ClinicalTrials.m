//
//  CNPostalAddress+ClinicalTrials.m
//  ClinicalTrials
//
//  Created by aarthur on 5/18/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import "CNPostalAddress+ClinicalTrials.h"
#import <Contacts/Contacts.h>

/**
 
 CONTACTS_EXTERN NSString * const CNPostalAddressStreetKey                            NS_AVAILABLE(10_11, 9_0);
 CONTACTS_EXTERN NSString * const CNPostalAddressSubLocalityKey                       NS_AVAILABLE(10_12_4, 10_3);
 CONTACTS_EXTERN NSString * const CNPostalAddressCityKey                              NS_AVAILABLE(10_11, 9_0);
 CONTACTS_EXTERN NSString * const CNPostalAddressSubAdministrativeAreaKey             NS_AVAILABLE(10_12_4, 10_3);
 CONTACTS_EXTERN NSString * const CNPostalAddressStateKey                             NS_AVAILABLE(10_11, 9_0);
 CONTACTS_EXTERN NSString * const CNPostalAddressPostalCodeKey                        NS_AVAILABLE(10_11, 9_0);
 CONTACTS_EXTERN NSString * const CNPostalAddressCountryKey                           NS_AVAILABLE(10_11, 9_0);
 CONTACTS_EXTERN NSString * const CNPostalAddressISOCountryCodeKey                    NS_AVAILABLE(10_11, 9_0);

 **/

@implementation CNPostalAddress (ClinicalTrials)

- (NSDictionary*)asGeoCodeDictionary
{
    NSMutableDictionary *geoDict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (self.postalCode) {
        geoDict[CNPostalAddressPostalCodeKey] = self.postalCode;
    }
    if (self.city) {
        geoDict[CNPostalAddressCityKey] = self.city;
    }
    if (self.country) {
        geoDict[CNPostalAddressCountryKey] = self.country;
    }
    if (self.ISOCountryCode) {
        geoDict[CNPostalAddressISOCountryCodeKey] = self.ISOCountryCode;
    }
    
    return [NSDictionary dictionaryWithDictionary:geoDict];
}

@end
