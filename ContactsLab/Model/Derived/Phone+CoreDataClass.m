//
//  Phone+CoreDataClass.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//
//

#import "Phone+CoreDataClass.h"
#import "CoreDataUtility.h"

@implementation Phone

+ (Phone*)createPhone:(NSString*)phone context:(NSManagedObjectContext*)ctx
{
    Phone *phoneObj;
    
    phoneObj = [[CoreDataUtility sharedInstance] insertNewPhoneWithEditContext:ctx];
    phoneObj.number = phone;
    
    return phoneObj;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    //all eos have a create date so set it here
    [self performSelector:@selector(setCreateDate:) withObject:[NSDate date]];
}

@end
