//
//  AddressTableCell.h
//  ContactsLab
//
//  Created by aarthur on 6/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *ADDRESS_CELL_ID;

@interface AddressTableCell : UITableViewCell

- (void)fillCellWithInfo:(NSDictionary*)addressInfo;
- (void)clear;

@end
