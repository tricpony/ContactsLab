//
//  GBAlerts.m
//  ClinicalTrials
//
//  Created by aarthur on 9/14/16.
//  Copyright © 2016 Gigabit LLC. All rights reserved.
//

#import "GBAlerts.h"

NSInteger BUTTON_ONE_ID = 0;
NSInteger BUTTON_TWO_ID = 1;
NSInteger BUTTON_THREE_ID = 2;
NSInteger CANCEL_BUTTON_ID = 3;

@implementation GBAlerts

+ (void)presentActionSheetWithTitle:(NSString*)title
                       buttonTitles:(NSArray*)buttonTitles
                           delegate:(id <UIPopoverPresentationControllerDelegate>)locationAgent
                      includeCancel:(BOOL)includeCancel
                            handler:(GBAlertIntCancelCompletion)handler
{
    UIAlertController* actionSheet = nil;
    UIAlertAction* cancelAction = nil;
    UIViewController *vc = (id)locationAgent;

    actionSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *nextTitle in buttonTitles) {
        UIAlertAction* buttonAction = nil;

        buttonAction = [UIAlertAction actionWithTitle:nextTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            handler([buttonTitles indexOfObject:nextTitle], NO);
        }];
        [actionSheet addAction:buttonAction];
    }

    if (includeCancel) {
        cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            handler(0,YES);
        }];
        [actionSheet addAction:cancelAction];
    }
    actionSheet.popoverPresentationController.delegate = locationAgent;
    [vc presentViewController:actionSheet animated:YES completion:NULL];
}

+ (void)presentOkAlertWithTitle:(NSString *)title
                     andMessage:(NSString *)message
                        handler:(GBAlertViewCompletion) handler
                 viewController:(UIViewController*)vc
{
    UIAlertController* alert = nil;
    UIAlertAction* defaultAction = nil;
    
    alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (handler) {
            handler(action);
        }
    }];
    
    [alert addAction:defaultAction];
    [vc presentViewController:alert animated:YES completion:NULL];
}

+ (void)presentOkAlertWithTitle:(NSString *)title andMessage:(NSString *)message handler:(GBAlertViewCompletion)handler
{
    UIViewController *vc = (id)APP_DELEGATE.window.rootViewController;
    [self presentOkAlertWithTitle:title andMessage:message handler:handler viewController:vc];
}

+ (void)presentTwoButtonAlertWithTitle:(NSString*)title
                            message:(NSString*)message
                     buttonTitleOne:(NSString*)titleOne
                     buttonTitleTwo:(NSString*)titleTwo
                      includeCancel:(BOOL)includeCancel
                        viewController:(UIViewController*)vc
                            handler:(GBAlertIntCompletion)whichButtonHandler
{
    UIAlertController* alert = nil;
    UIAlertAction* buttonOneAction = nil;
    UIAlertAction* buttonTwoAction = nil;
    UIAlertAction* cancelAction = nil;
    
    if (!vc) {
        vc = (id)APP_DELEGATE.window.rootViewController;
    }
    
    alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    buttonOneAction = [UIAlertAction actionWithTitle:titleOne style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        whichButtonHandler(BUTTON_ONE_ID);
    }];
    buttonTwoAction = [UIAlertAction actionWithTitle:titleTwo style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        whichButtonHandler(BUTTON_TWO_ID);
    }];
    
    [alert addAction:buttonOneAction];
    [alert addAction:buttonTwoAction];
    
    if (includeCancel) {
        cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            whichButtonHandler(CANCEL_BUTTON_ID);
        }];
        [alert addAction:cancelAction];
    }
    
    [vc presentViewController:alert animated:YES completion:NULL];
}

+ (void)presentTwoButtonAlertWithTitle:(NSString*)title
                            message:(NSString*)message
                     buttonTitleOne:(NSString*)titleOne
                     buttonTitleTwo:(NSString*)titleTwo
                        viewController:(UIViewController*)vc
                            handler:(GBAlertIntCompletion)whichButtonHandler
{
    [self presentTwoButtonAlertWithTitle:title message:message
                       buttonTitleOne:titleOne
                       buttonTitleTwo:titleTwo
                        includeCancel:YES
                          viewController:vc
                              handler:^(NSInteger whichChoice) {
                                  
                                  whichButtonHandler(whichChoice);
                                  
                              }];
}

@end
