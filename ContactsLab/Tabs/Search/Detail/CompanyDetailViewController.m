//
//  CompanyDetailViewController.m
//  ContactsLab
//
//  Created by aarthur on 6/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "CompanyDetailViewController.h"
#import "AddressTableCell.h"
#import "Constants.h"

#import "UIColor+ContactsLab.h"
#import "Phone+CoreDataClass.h"
#import "Address+CoreDataClass.h"

@interface CompanyDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UIView *topCanvas;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UIView *bottomCanvas;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groupedSearchResults;

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

#pragma mark Table view methods

- (NSString*)cellIdentifierAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        return ADDRESS_CELL_ID;
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
    
    nextItem = contacts[indexPath.row];
    
    if (indexPath.section == 0) {
        AddressTableCell *addressCell = (id)cell;
        
        [addressCell clear];
        [addressCell fillCellWithInfo:nextItem.addressAsDictionary];
        
    }else{
        Phone *phone = (id)nextItem;
        NSString *titleText;

        titleText = phone.number;
        cell.textLabel.text = titleText;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

@end
