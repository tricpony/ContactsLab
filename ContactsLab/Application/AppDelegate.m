//
//  AppDelegate.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

#import "Company+CoreDataClass.h"
#import "Person+CoreDataClass.h"
#import "ContactsLabService.h"
#import "CoreDataUtility.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    ContactsLabService *service;
    __weak __typeof(self)weakSelf = self;
    
    service = [[ContactsLabService alloc] init];
    service.serviceAddress = SERVICE_ADDRESS;
    [service startServiceBlock:^(NSError *error, NSData *data) {
        if (!error && data) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray *contacts;
            NSManagedObjectContext *ctx = strongSelf.managedObjectContext;
            NSMutableArray *companies = [NSMutableArray arrayWithCapacity:5];
            
            contacts = responseDict[@"contacts"];
            for (NSDictionary *nextItem in contacts) {
                
                if (nextItem[COMPANY_NAME]) {
                    Company *company;
                    
                    company = [Company createCompanyWithInfo:nextItem editContext:ctx];
                    if (company) {
                        [companies addObject:company];
                    }
                    
                }else if (nextItem[PERSON_NAME]) {
                    Person *person;
                    
                    person = [Person createPersonNamed:nextItem[PERSON_NAME] withContext:ctx];
                    [person fillPhonesFrom:nextItem[PERSON_PHONES] context:ctx];
                    [person fillAddressesFrom:nextItem[PERSON_ADDRESSES] context:ctx];
                }
            }
            NSInteger i = 0;
            
            //pass thru these once more for good measure
            while (i < [companies count]) {
                Company *nextCompany = companies[i++];
                
                [nextCompany fillCompanyBrandsWithContext:ctx];
            }
            [[CoreDataUtility sharedInstance] persistContext:ctx wait:NO];

        }else if (error) {
            NSLog(@"SERVICE FAILURE: %@",[error localizedDescription]);
        }
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;
@synthesize managedObjectContext = _managedObjectContext;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"ContactsLab"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[self persistentContainer] viewContext];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
