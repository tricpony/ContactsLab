//
//  CNPostalAddress+ClinicalTrials.h
//  ClinicalTrials
//
//  Created by aarthur on 5/18/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <Contacts/Contacts.h>

@interface CNPostalAddress (ClinicalTrials)

- (NSDictionary*)asGeoCodeDictionary;

@end
