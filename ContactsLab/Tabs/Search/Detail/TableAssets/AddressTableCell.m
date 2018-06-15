//
//  AddressTableCell.m
//  ContactsLab
//
//  Created by aarthur on 6/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "AddressTableCell.h"
#import "Constants.h"

NSString *ADDRESS_CELL_ID = @"ADDRESS_CELL_ID";

@interface AddressTableCell()
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;


@end

@implementation AddressTableCell


- (void)fillCellWithInfo:(NSDictionary*)addressInfo
{
    self.streetLabel.text = addressInfo[STREET_KEY];
    self.cityLabel.text = addressInfo[CITY_KEY];
    self.stateLabel.text = addressInfo[STATE_KEY];
    self.zipLabel.text = addressInfo[ZIP_KEY];
    
}

- (void)clear
{
    self.streetLabel.text = @"";
    self.cityLabel.text = @"";
    self.stateLabel.text = @"";
    self.zipLabel.text = @"";
    
}

@end
