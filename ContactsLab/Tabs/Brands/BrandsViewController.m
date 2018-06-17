//
//  BrandsViewController.m
//  ContactsLab
//
//  Created by aarthur on 6/16/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "BrandsViewController.h"
#import "CompanyDetailViewController.h"
#import <CoreData/CoreData.h>
#import "CoreDataUtility.h"
#import "Constants.h"

#import "Company+CoreDataClass.h"

@interface BrandsViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BrandsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Brands";
    [self configureFetchResultsConstroller];
    
    //enable auto cell height that uses constraints
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55;
}

- (void)configureFetchResultsConstroller
{
    if (self.fetchedResultsController == nil) {
        NSFetchRequest *request = nil;
        NSError *error;
        BOOL success;
        NSManagedObjectContext *ctx = [APP_DELEGATE managedObjectContext];

        request = [[CoreDataUtility sharedInstance] fetchRequestForBrandsWithEditContext:ctx];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:ctx
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        success = [self.fetchedResultsController performFetch:&error];
        if (success == NO) {
            NSLog(@"Fetch Failure: %@", [error localizedDescription]);
        }else{
            NSLog(@"fetched results count %lu",(unsigned long)[self.fetchedResultsController.fetchedObjects count]);
            [self.tableView reloadData];
        }
    }
}

#pragma mark Table view methods

- (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleSubtitle;
}

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
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    numberOfRows = [sectionInfo numberOfObjects];
    
    return numberOfRows;
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = nil;
    Company *company = nil;
    
    cell = [self nextCellForTableView:tv atIndexPath:indexPath];
    company = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = company.displayName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Company *company = nil;

    [tv deselectRowAtIndexPath:indexPath animated:YES];
    company = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"detailCompanySegue" sender:company];
}

#pragma mark StoryBoard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailCompanySegue"]) {
        UINavigationController *navVC = segue.destinationViewController;
        CompanyDetailViewController *vc = (id)navVC.topViewController;
        Company *company = sender;
        
        self.navigationItem.title = @" ";
        vc.company = company;
        vc.title = [NSString stringWithFormat:@"%@ Details",company.name];
        vc.companyTitle = @"Brand";
    }
}

@end
