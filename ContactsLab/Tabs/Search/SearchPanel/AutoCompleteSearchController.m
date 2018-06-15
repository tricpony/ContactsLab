//
//  AutoCompleteSearchController.m
//  ClinicalTrials
//
//  Created by aarthur on 8/22/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import "AutoCompleteSearchController.h"
#import "SearchViewController.h"
#import "Constants.h"

#import "Company+CoreDataClass.h"
#import "Person+CoreDataClass.h"
#import "UIColor+ContactsLab.h"
#import "NSString+ContactsLab.h"

@interface AutoCompleteSearchController ()

@end

@implementation AutoCompleteSearchController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //this fixed a gap above the top of the table view
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView setIsAccessibilityElement:YES];
    self.searchController.searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, 2);
    //searchBar.searchFieldBackgroundPositionAdjustment
}

#pragma mark Table view methods

- (NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    return NSStringFromClass([self class]);
}

- (UITableViewCell*)nextCellForTableView:(UITableView*)aTableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self cellIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.adjustsFontSizeToFitWidth = NO;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.searchControllerSearchArgs count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *frc = self.searchControllerSearchArgs[section][FRC];

    numberOfRows = [[frc fetchedObjects] count];
    return numberOfRows;
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor GBBlue];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];
    NSString *title = @"";
    NSFetchedResultsController *frc = self.searchControllerSearchArgs[section][FRC];
    BOOL isPerson = [[[frc fetchedObjects] firstObject] isKindOfClass:[Person class]];
    
    if (numberOfRows > 1) {
        title = ((isPerson)?@"Suggested People":@"Susggested Companies");
    }else if (numberOfRows == 1) {
        title = ((isPerson)?@"Suggested Person":@"Susggested Company");
    }
    
    return title;
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *frc = self.searchControllerSearchArgs[indexPath.section][FRC];
    UITableViewCell *cell = [self nextCellForTableView:tv atIndexPath:indexPath];
    NSString *titleText;
    NSRange r;
    Company *nextItem = nil;
    
    nextItem = [frc fetchedObjects][indexPath.row];
    titleText = [nextItem valueForKey:@"searchTerm"];

    r = [titleText rangeOfString:self.searchController.searchBar.text options:NSCaseInsensitiveSearch];
    cell.textLabel.attributedText = [titleText attributedStringHighlightingRange:r color:[UIColor yellowColor]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *frc = self.searchControllerSearchArgs[indexPath.section][FRC];
    Company *nextItem = nil;
    SearchViewController *vc;
    
    vc = (id)self.searchController.searchResultsUpdater;
    nextItem = [frc fetchedObjects][indexPath.row];
    
    [self.searchController setActive:NO];
    self.searchController.searchBar.text = [nextItem searchTerm];
    [vc assembleDataSourceFrom:nextItem];
}

@end
