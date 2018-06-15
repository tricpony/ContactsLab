//
//  SearchViewController.h
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SearchViewController : UIViewController

- (void)assembleDataSourceFrom:(NSManagedObject*)searchTerm;

@end
