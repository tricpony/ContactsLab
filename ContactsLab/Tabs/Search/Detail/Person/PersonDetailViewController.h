//
//  PersonDetailViewController.h
//  ContactsLab
//
//  Created by aarthur on 6/16/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person+CoreDataClass.h"

@interface PersonDetailViewController : UIViewController
@property (strong, nonatomic) Person *person;

@end
