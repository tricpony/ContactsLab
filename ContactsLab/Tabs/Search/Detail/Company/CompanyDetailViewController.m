//
//  CompanyDetailViewController.m
//  ContactsLab
//
//  Created by aarthur on 6/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "CompanyDetailViewController.h"
#import <Contacts/Contacts.h>
#import "AddressTableCell.h"
#import "MapViewController.h"
#import "ChromePresentationController.h"
#import "GBSplitViewController.h"
#import "Constants.h"

#import "UIColor+ContactsLab.h"
#import "Phone+CoreDataClass.h"
#import "Address+CoreDataClass.h"

@interface CompanyDetailViewController () <UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UIView *topCanvas;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UIView *bottomCanvas;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groupedSearchResults;
@property (strong, nonatomic) ChromeTransitioningDelegate *transitionDelegate;

@end

@implementation CompanyDetailViewController

- (void)registerTableAssets
{
    UINib *nib;
    
    nib = [UINib nibWithNibName:@"AddressTableCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:ADDRESS_CELL_ID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerTableAssets];
    [self applyBorderAndShadow];
    [self assembleDataSource];
    [self loadTableFooter];
    self.detailTitle.text = self.companyTitle;
    self.canvas.hidden = self.company == nil;
    //enable auto cell height that uses constraints
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadTableFooter
{
    UIView *footer = [[UIView alloc] init];
    self.tableView.tableFooterView = footer;
}

- (void)applyBorderAndShadow
{
    CALayer *layer = self.canvas.layer;
    
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.borderWidth = 0.4;
    layer.cornerRadius = 6.25;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(3, 1);
    layer.shadowOpacity = 1.0;
    layer.shadowRadius = 3.0;
    layer.shouldRasterize = YES;
    
    layer = self.topCanvas.layer;
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.borderWidth = 0.4;
    layer.cornerRadius = 6.25;
    
    layer = self.bottomCanvas.layer;
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.borderWidth = 0.4;
    layer.cornerRadius = 6.25;
}

- (void)assembleDataSource
{
    self.groupedSearchResults = [NSMutableArray arrayWithCapacity:4];
    if (self.company.hasAddresses) {
            [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_Address),GROUP_DATA_KEY:[self.company.addresses allObjects]}];
    }
    if (self.company.hasPhones) {
        [self.groupedSearchResults addObject:@{GROUP_TYPE_KEY:@(GroupedBy_Phone),GROUP_DATA_KEY:[self.company.phones allObjects]}];
    }
}

#pragma mark Map

- (void)handleLocationTapFor:(Address*)address
{
    UINavigationController *nav = nil;
    MapViewController *map = nil;
    CNMutablePostalAddress *studyLocation = [[CNMutablePostalAddress alloc] init];
    
    if (address.street) {
        studyLocation.street = address.street;
    }
    if (address.zip) {
        studyLocation.postalCode = address.zip;
    }
    if (address.city) {
        studyLocation.city = address.city;
    }
    
    map = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    map.addressInfo = studyLocation;
    map.isModal = YES;
    nav = [[UINavigationController alloc] initWithRootViewController:map];
    if (address.company) {
        map.topTitle = [NSString stringWithFormat:@"%@ Location",address.company.name];
        map.bottomTitle = [NSString stringWithFormat:@"%@, %@",address.street,address.city];
    }
    
    UIUserInterfaceSizeClass hSizeClass = [APP_DELEGATE window].traitCollection.horizontalSizeClass;
    if (hSizeClass == UIUserInterfaceSizeClassRegular) {
        self.transitionDelegate = [[ChromeTransitioningDelegate alloc] init];
        nav.modalPresentationStyle = UIModalPresentationCustom;
        nav.transitioningDelegate = self.transitionDelegate;
    }
    [self presentViewController:nav animated:YES completion:nil];
    if (hSizeClass == UIUserInterfaceSizeClassRegular) {
        id <UISplitViewControllerDelegate> spvDelegate = (id)nav.presentationController;
        [((GBSplitViewController*)self.splitViewController) assignNextActiveForwardDelegate:spvDelegate];
    }
}

#pragma mark Table view methods

- (NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    GroupedByType groupedByType = [self.groupedSearchResults[indexPath.section][GROUP_TYPE_KEY] integerValue];
    
    switch (groupedByType) {
        case GroupedBy_Address:
            return ADDRESS_CELL_ID;

        default:
            break;
    }

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
        case GroupedBy_Address:
            title = NSLocalizedString(@"Addresses", nil);
            break;
            
        case GroupedBy_Phone:
            title = NSLocalizedString(@"Phones", nil);
            break;
                        
        default:
            break;
    }
    
    return title;
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contacts = self.groupedSearchResults[indexPath.section][GROUP_DATA_KEY];    
    UITableViewCell *cell = [self nextCellForTableView:tv atIndexPath:indexPath];
    Address *nextItem = nil;
    GroupedByType groupedByType = [self.groupedSearchResults[indexPath.section][GROUP_TYPE_KEY] integerValue];
    AddressTableCell *addressCell;
    Phone *phone;
    NSString *titleText;

    nextItem = contacts[indexPath.row];
    switch (groupedByType) {
        case GroupedBy_Address:
            addressCell = (id)cell;
            [addressCell clear];
            [addressCell fillCellWithInfo:nextItem.addressAsDictionary];

            break;
            
        case GroupedBy_Phone:
            phone = (id)nextItem;
            
            titleText = phone.number;
            cell.textLabel.text = titleText;

            break;
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *contacts = self.groupedSearchResults[indexPath.section][GROUP_DATA_KEY];
    Address *nextItem = nil;
    GroupedByType groupedByType = [self.groupedSearchResults[indexPath.section][GROUP_TYPE_KEY] integerValue];
    
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    nextItem = contacts[indexPath.row];
    switch (groupedByType) {
        case GroupedBy_Address:
            [self handleLocationTapFor:nextItem];
            
            break;
            
        case GroupedBy_Phone:
            
            break;
        default:
            break;
    }
}

@end
