//
//  GBAlerts.h
//  ClinicalTrials
//
//  Created by aarthur on 9/14/16.
//  Copyright © 2016 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

typedef void (^GBAlertIntCancelCompletion)(NSInteger,BOOL);
typedef void (^GBAlertIntCompletion)(NSInteger);
typedef void (^GBAlertViewCompletion)(UIAlertAction*);

extern NSInteger BUTTON_ONE_ID;
extern NSInteger BUTTON_TWO_ID;
extern NSInteger BUTTON_THREE_ID;
extern NSInteger CANCEL_BUTTON_ID;

@interface GBAlerts : NSObject

+ (void)presentActionSheetWithTitle:(NSString*)title
                       buttonTitles:(NSArray*)buttonTitles
                           delegate:(id <UIPopoverPresentationControllerDelegate>)locationAgent
                      includeCancel:(BOOL)includeCancel
                            handler:(GBAlertIntCancelCompletion)handler;

+ (void)presentOkAlertWithTitle:(NSString *)title andMessage:(NSString *)message handler:(GBAlertViewCompletion)handler;
+ (void)presentOkAlertWithTitle:(NSString *)title
                     andMessage:(NSString *)message
                        handler:(GBAlertViewCompletion) handler
                 viewController:(UIViewController*)vc;

+ (void)presentTwoButtonAlertWithTitle:(NSString*)title
                               message:(NSString*)message
                        buttonTitleOne:(NSString*)titleOne
                        buttonTitleTwo:(NSString*)titleTwo
                         includeCancel:(BOOL)includeCancel
                        viewController:(UIViewController*)vc
                               handler:(GBAlertIntCompletion)whichButtonHandler;

@end
