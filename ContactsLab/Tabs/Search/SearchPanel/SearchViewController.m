//
//  SearchViewController.m
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "SearchViewController.h"
#import "AutoCompleteSearchController.h"
#import "CompanyDetailViewController.h"
#import "CoreDataUtility.h"
#import "Constants.h"

#import "UIView+ContactsLab.h"
#import "Company+CoreDataClass.h"
#import "UIColor+ContactsLab.h"
#import "Person+CoreDataClass.h"

@interface SearchViewController () <UISearchResultsUpdating>
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *searchControllerSearchArgs;
@property (strong, nonatomic) NSMutableArray *groupedSearchResults;
@property (readonly, nonatomic) AutoCompleteSearchController *autoCompleteSearchController;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchBarCanvas;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //alert me when the keyboard is about to display
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(keyboardWillShow:)
                                                     name: UIKeyboardWillShowNotification
                                                   object: nil];
        
        //alert me when the keyboard is about to dismiss
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(keyboardWillDismiss:)
                                                     name: UIKeyboardWillHideNotification
                                                   object: nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Search Contacts";
}

#pragma mark SearchBar Controller

- (void)configureFRCWithSearchText:(NSString*)searchTerm
{
    NSError *error;
    BOOL success;
    NSManagedObjectContext *ctx = [APP_DELEGATE managedObjectContext];
    AutoCompleteSearchController *vc;
    
    vc = self.autoCompleteSearchController;
    
    if ([self isFiltering]) {
        NSFetchRequest *request = nil;
        NSFetchedResultsController *frc;
        
        self.searchControllerSearchArgs = [NSMutableArray arrayWithCapacity:2];
        request = [[CoreDataUtility sharedInstance] fetchRequestForCompanyContainingSearchTerm:searchTerm withEditContext:ctx];
        frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                  managedObjectContext:ctx
                                                    sectionNameKeyPath:nil
                                                             cacheName:nil];
        success = [frc performFetch:&error];
        if (success == NO) {
            NSLog(@"Fetch Failure: %@", [error localizedDescription]);
        }else{
            if ([frc.fetchedObjects count] > 0) {
                [self.searchControllerSearchArgs addObject:@{FRC:frc}];
            }
            NSLog(@"fetched results count %lu",(unsigned long)[frc.fetchedObjects count]);
        }
        
        request = [[CoreDataUtility sharedInstance] fetchRequestForPersonContainingSearchTerm:searchTerm withEditContext:ctx];
        frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                  managedObjectContext:ctx
                                                    sectionNameKeyPath:nil
                                                             cacheName:nil];

        success = [frc performFetch:&error];
        if (success == NO) {
            NSLog(@"Fetch Failure: %@", [error localizedDescription]);
        }else{
            if ([frc.fetchedObjects count] > 0) {
                [self.searchControllerSearchArgs addObject:@{FRC:frc}];
            }
            NSLog(@"fetched results count %lu",(unsigned long)[frc.fetchedObjects count]);
        }
        vc.searchControllerSearchArgs = self.searchControllerSearchArgs;
    }
    
}

- (void)setupSearchController
{
    AutoCompleteSearchController *autoCompleteVC;
    UIStoryboard *sb = [self storyboard];
    
    autoCompleteVC = [sb instantiateViewControllerWithIdentifier:@"AutoCompleteScene"];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:autoCompleteVC];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    self.definesPresentationContext = YES;
    autoCompleteVC.searchControllerSearchArgs = self.searchControllerSearchArgs;
    autoCompleteVC.searchController = self.searchController;
    self.searchBar = self.searchController.searchBar;
    [self.searchBar setAccessibilityLabel:@"search bar"];
    
    //insert the search bar
    [self.searchBarCanvas addSubview:self.searchController.searchBar];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController*)searchController
{
    AutoCompleteSearchController *vc;
    
    self.tableView.hidden = YES;
    vc = (id)[searchController searchResultsController];
    [self searchBarShouldBeginEditing:searchController.searchBar];
    [self configureFRCWithSearchText:searchController.searchBar.text];
    [vc.tableView reloadData];
    [searchController.searchBar setAccessibilityValue:searchController.searchBar.text];
}

#pragma mark UISearchController Helper

- (void)viewDidLayoutSubviews
{
    CGFloat w;
    CGRect frame;
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    
    w = self.view.frame.size.width;
    frame = CGRectMake(searchBarFrame.origin.x, searchBarFrame.origin.y, w, searchBarFrame.size.height);
    self.searchController.searchBar.frame = frame;
}

- (BOOL)searchBarIsEmpty
{
    return [self.searchController.searchBar.text length] == 0;
}

- (BOOL)isFiltering
{
    return self.searchController.isActive && ![self searchBarIsEmpty];
}

- (AutoCompleteSearchController*)autoCompleteSearchController
{
    return (id)[self.searchController searchResultsController];
}

#pragma mark keyboard notification/actions

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self insertKeyboardToolbar];
    self.searchBar = searchBar;
    return YES;
}

- (void)insertKeyboardToolbar
{
    if (self.keyboardToolbar == nil) {
        CGRect subFrame;
        CGRect baseFrame;
        CGFloat h = TOOL_BAR_HEIGHT;
        UIBarButtonItem *barButtonItemDone = nil;
        UIBarButtonItem *flexItem = nil;
        
        baseFrame = self.view.frame;
        subFrame = CGRectMake(0, baseFrame.size.height, baseFrame.size.width, h);
        self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:subFrame];
        self.keyboardToolbar.barStyle = UIBarStyleDefault;
        
        flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                 target:nil
                                                                 action:NULL];
        
        barButtonItemDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(keyboardDone:)];
        
        barButtonItemDone.style = UIBarButtonItemStyleDone;
        NSArray *items = @[flexItem,barButtonItemDone];
        [self.keyboardToolbar setItems:items];
        [self.view addSubview:self.keyboardToolbar];
        
    }
    
}

- (void)keyboardDone:(id)sender
{
    [self.searchBar resignFirstResponder];
}

/**
 http://stackoverflow.com/questions/7327249/ios-how-to-convert-uiviewanimationcurve-to-uiviewanimationoptions
 **/
static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve)
{
    UIViewAnimationOptions opt = (UIViewAnimationOptions)curve;
    return opt << 16;
}

/**
 Animates a toolbar into view with the keyboard
 http://stackoverflow.com/questions/1951826/move-up-uitoolbar
 **/
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect beginKeyboardFrame;
    CGRect endKeyboardFrame;
    CGFloat h = TOOL_BAR_HEIGHT;
    CGRect subFrame;
    UINavigationBar *navBar = nil;
    
    navBar = [[self navigationController] navigationBar];
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [userInfo[UIKeyboardFrameBeginUserInfoKey] getValue:&beginKeyboardFrame];
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&endKeyboardFrame];
    
    self.keyboardToolbar.frame = beginKeyboardFrame;
    subFrame = CGRectMake(0, endKeyboardFrame.origin.y - h, endKeyboardFrame.size.width, h);
    
    //this code works but not on iOS3
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^{
                         
                         self.keyboardToolbar.frame = subFrame;
                         
                     }
                     completion:nil];
    
}

/**
 Animates a toolbar out of view with the keyboard
 **/
- (void)keyboardWillDismiss:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGFloat h = TOOL_BAR_HEIGHT;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^{
                         CGRect subFrame;
                         CGRect baseFrame;
                         
                         baseFrame = self.view.frame;
                         subFrame = CGRectMake(0, baseFrame.size.height, baseFrame.size.width, h);
                         self.keyboardToolbar.frame = subFrame;
                         
                     }
                     completion:nil];
}

#pragma mark Grouped Search

- (void)performGroupedResultsSearchForSearchTerm:(NSManagedObject*)contact
{
    BOOL isPerson = [contact isKindOfClass:[Person class]];

    self.groupedSearchResults = [NSMutableArray arrayWithCapacity:4];
    if (isPerson) {
        Person *person = (id)contact;
        
        if (person.company) {
            [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_Person_Company),GROUP_DATA_KEY:@[person.company]}];
        }
        [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_Person),GROUP_DATA_KEY:@[person]}];
        
    }else{
        Company *company = (id)contact;
        
        if (company.isCorpOwner) {
            [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_CorpOwner),GROUP_DATA_KEY:@[company]}];
        }
        if (company.hasCorpOwners) {
            [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_CorpOwner),GROUP_DATA_KEY:[company.corpOwners allObjects]}];
        }
        if (company.hasBrands) {
            [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_Brand),GROUP_DATA_KEY:[company.brands allObjects]}];
        }
        if (company.hasManagers) {
            [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_Manager),GROUP_DATA_KEY:[company.managers allObjects]}];
        }
    }
    
    self.tableView.hidden = [self.groupedSearchResults count] == 0;
    if (!self.tableView.hidden) {
        [self.tableView reloadData];
    }
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
    return [self.groupedSearchResults count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSArray *contacts = self.groupedSearchResults[section][GROUP_DATA_KEY];

    numberOfRows = [contacts count];
    return numberOfRows;
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor teal];
    
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
    GroupedByType groupedByType = [self.groupedSearchResults[section][GROUP_TYPE_KEY] integerValue];
    NSString *title = NSLocalizedString(@"Unknown", nil);
    
    switch (groupedByType) {
        case GroupedBy_CorpOwner:
            title = NSLocalizedString(@"Corporate Owners", nil);
            break;
            
        case GroupedBy_Brand:
            title = NSLocalizedString(@"Brands", nil);
            break;
            
        case GroupedBy_Manager:
            title = NSLocalizedString(@"Managers", nil);
            break;
            
        case GroupedBy_Person:
            title = NSLocalizedString(@"Contact", nil);
            break;
            
        case GroupedBy_Person_Company:
            title = NSLocalizedString(@"Manager At", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contacts = self.groupedSearchResults[indexPath.section][GROUP_DATA_KEY];
    GroupedByType groupedByType = [self.groupedSearchResults[indexPath.section][GROUP_TYPE_KEY] integerValue];

    UITableViewCell *cell = [self nextCellForTableView:tv atIndexPath:indexPath];
    NSString *titleText;
    Company *nextItem = nil;

    nextItem = contacts[indexPath.row];
    titleText = nextItem.displayName;

    cell.textLabel.text = titleText;
    
    switch (groupedByType) {
        case GroupedBy_Person:
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
            
        default:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            break;
    }


    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contacts = self.groupedSearchResults[indexPath.section][GROUP_DATA_KEY];
    GroupedByType groupedByType = [self.groupedSearchResults[indexPath.section][GROUP_TYPE_KEY] integerValue];
    Company *nextItem = nil;
    BOOL isPerson = NO;
    Person *person = (id)nextItem;

    nextItem = contacts[indexPath.row];
    isPerson = [nextItem isKindOfClass:[Person class]];
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (groupedByType) {
        case GroupedBy_CorpOwner:
        case GroupedBy_Brand:
        case GroupedBy_Person_Company:

            [self performSegueWithIdentifier:@"detailSegue" sender:nextItem];
            break;
           
        case GroupedBy_Manager:
            
            person = (id)nextItem;
            nextItem = person.company;
            [self performSegueWithIdentifier:@"detailSegue" sender:nextItem];
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        UINavigationController *navVC = segue.destinationViewController;
        CompanyDetailViewController *vc = (id)navVC.topViewController;
        Company *company = sender;

        self.navigationItem.title = @" ";
        vc.company = company;
        vc.title = [NSString stringWithFormat:@"%@ Details",company.name];
        
        if ([company.brands count]) {
            vc.companyTitle = @"Corporate Owner";
        }else{
            vc.companyTitle = @"Brand";
        }
    }
}

@end
