//
//  MapViewController.h
//  ClinicalTrials
//
//  Created by aarthur on 2/22/15.
//  Copyright (c) 2015 Gigabit LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CNMutablePostalAddress;
@interface MapViewController : UIViewController
@property (nonatomic, strong) CNMutablePostalAddress *addressInfo;
@property (strong, nonatomic) NSString *researchCenterName;
@property (nonatomic, assign) BOOL isModal;

@end
