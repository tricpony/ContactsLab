//
//  CompanyDetailViewController.h
//  ContactsLab
//
//  Created by aarthur on 6/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Company+CoreDataClass.h"

@interface CompanyDetailViewController : UIViewController
@property (strong, nonatomic) Company *company;
@property (strong, nonatomic) NSString *companyTitle;

@end
