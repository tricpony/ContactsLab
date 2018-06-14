//
//  SearchViewController.m
//  ContactsLab
//
//  Created by aarthur on 6/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "SearchViewController.h"
#import "AutoCompleteSearchController.h"
#import "CoreDataUtility.h"
#import "Constants.h"

#import "UIView+ContactsLab.h"

@interface SearchViewController () <UISearchResultsUpdating>
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *searchControllerSearchArgs;
@property (readonly, nonatomic) AutoCompleteSearchController *autoCompleteSearchController;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (weak, nonatomic) IBOutlet UIView *searchBarCanvas;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchController];
    
    
//    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

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

#pragma mark SearchBar Controller

- (void)configureFRCWithSearchText:(NSString*)searchText
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
        request = [[CoreDataUtility sharedInstance] fetchRequestForCompanyContainingSearchTerm:searchText withEditContext:ctx];
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
        
        request = [[CoreDataUtility sharedInstance] fetchRequestForPersonContainingSearchTerm:searchText withEditContext:ctx];
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
//    self.searchController.searchBar.barTintColor = self.navigationController.navigationBar.backgroundColor;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    self.definesPresentationContext = YES;
    autoCompleteVC.searchControllerSearchArgs = self.searchControllerSearchArgs;
    autoCompleteVC.searchController = self.searchController;
    self.searchBar = self.searchController.searchBar;
    [self.searchBar setAccessibilityLabel:@"search bar"];
    
    //insert the search bar
    [self.searchBarCanvas addSubview:self.searchController.searchBar];
//    [self.searchBarCanvas pinnView:self.searchController.searchBar toEdgeOffsets:EdgeOffsetMake(0, 0, 0, 0)];
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController*)searchController
{
    AutoCompleteSearchController *vc;
    
    vc = (id)[searchController searchResultsController];
    [self searchBarShouldBeginEditing:searchController.searchBar];
    [self configureFRCWithSearchText:searchController.searchBar.text];
    [vc.tableView reloadData];
    [searchController.searchBar setAccessibilityValue:searchController.searchBar.text];
}

#pragma mark UISearchController Helper

//- (void)viewDidLayoutSubviews
//{
//    CGFloat w;
//    CGRect frame;
//    CGRect searchBarFrame = self.searchController.searchBar.frame;
//    
//    w = self.view.frame.size.width;
//    frame = CGRectMake(searchBarFrame.origin.x, searchBarFrame.origin.y, w, searchBarFrame.size.height + 22);
//    frame = CGRectMake(searchBarFrame.origin.x, searchBarFrame.origin.y, w, searchBarFrame.size.height);
//    self.searchController.searchBar.frame = frame;
//}

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
//    NSFetchedResultsController *frc = self.searchControllerSearchArgs[section][FRC];
//
//    numberOfRows = [[frc fetchedObjects] count];
    return numberOfRows;
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSFetchedResultsController *frc = self.searchControllerSearchArgs[indexPath.section][FRC];
    UITableViewCell *cell = nil;//[self nextCellForTableView:tv atIndexPath:indexPath];
//    NSString *titleText;
//    NSRange r;
//    Company *nextItem = nil;
//
//    nextItem = [frc fetchedObjects][indexPath.row];
//    titleText = [nextItem valueForKey:@"searchTerm"];
//
//    r = [titleText rangeOfString:self.searchController.searchBar.text options:NSCaseInsensitiveSearch];
//    cell.textLabel.attributedText = [titleText attributedStringHighlightingRange:r color:[UIColor yellowColor]];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSFetchedResultsController *frc = self.searchControllerSearchArgs[indexPath.section][FRC];
    //    NSString *titleText;
    //    CTSearchableStudyClass *nextItem = nil;
    //    SearchViewController *vc;
    //
    //    vc = (id)self.searchController.searchResultsUpdater;
    //    nextItem = [frc fetchedObjects][indexPath.row];
    //
    //    if (frc == vc.searchedBeforeFRC) {
    //        NSManagedObjectContext *ctx = [APP_DELEGATE managedObjectContext];
    //        NSMutableDictionary *searchArgs = nil;
    //        NSMutableDictionary *reverseSearchArgs = nil;
    //        ArchivedSearch *archiveSearch = [ctx objectWithID:[nextItem valueForKey:@"objectID"]];
    //        __block NSMutableArray *searchRequestArgsForInsert = [NSMutableArray arrayWithCapacity:[searchArgs count]];
    //
    //        searchArgs = archiveSearch.argsFromSearchURL;
    //        reverseSearchArgs = [NSMutableDictionary dictionaryWithCapacity:[searchArgs count]];
    //        for (NSString *nextKey in [searchArgs allKeys]) {
    //
    //            reverseSearchArgs[nextKey] = [vc reverseValueForArg:searchArgs[nextKey]
    //                                                      ofArgMask:nextKey
    //                                                     completion:^(NSString *selectorString, NSInteger indexOfArg) {
    //                                                         [searchRequestArgsForInsert addObject:@{@"queryBuildingSelector":selectorString,@"index":@(indexOfArg)}];
    //                                                     }];
    //
    //        }
    //        [vc highlightGridCellsMatchingSearchArgs:reverseSearchArgs];
    //
    //        //now insert the search request args and the service call is ready to fire
    //        for (NSDictionary *nextInfo in searchRequestArgsForInsert) {
    //            SEL selector;
    //
    //            selector = NSSelectorFromString(nextInfo[@"queryBuildingSelector"]);
    //            [vc performInvocationWithSelector:selector object:nextInfo[@"index"]];
    //        }
    //
    //        titleText = [nextItem valueForKey:@"searchTerm"];
    //
    //    }else{
    //        titleText = [nextItem displayKey];
    //    }
    //
    //    [self.searchController setActive:NO];
    //    self.searchController.searchBar.text = titleText;
    
}

@end