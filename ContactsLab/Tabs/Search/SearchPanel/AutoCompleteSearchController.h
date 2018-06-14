//
//  AutoCompleteSearchController.h
//  ClinicalTrials
//
//  Created by aarthur on 8/22/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCompleteSearchController : UITableViewController
@property (weak, nonatomic) NSMutableArray *searchControllerSearchArgs;
@property (weak, nonatomic) UISearchController *searchController;

@end
