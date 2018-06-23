//
//  AppDelegate.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import <MagicalRecord/MagicalRecord.h>
#import "GBAlerts.h"
#import "SyncManager.h"
#import "CoreDataUtility.h"
#import <netinet/in.h>

@interface AppDelegate ()
@property (nonatomic, strong) NSThread *reachabilityThread;
@property (nonatomic, assign) BOOL networkFailureAlertWasDisplayed;
@property (nonatomic, assign) NetworkStatus internetConnectionStatus;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    id ctx;
    
    /** REACHABILITY **/
    ///////////////////////////////////////////
    //
    //configure reachability
    [self startReachability];
    //
    ///////////////////////////////////////////

    //fire up the core data stack
    ctx = self.managedObjectContext;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[SyncManager sharedManager] syncContactsWithCompltionBlock:^(BOOL passed, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[CoreDataUtility sharedInstance] persistContext:self.managedObjectContext wait:NO];
            });
        }];
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

- (void)displayAlertWithTitle:(NSString*)title message:(NSString*)message
{
    [GBAlerts presentOkAlertWithTitle:((title?title:GENERIC_LOCALIZED_ALERT_TITLE)) andMessage:message handler:NULL];
}

#pragma mark -
#pragma mark Reachability

/**
 configure reachability
 **/
- (void)startReachability
{
    if (!self.reachabilityThread) {
        self.networkFailureAlertWasDisplayed = NO;
        self.reachabilityThread = [[NSThread alloc] initWithTarget:self
                                                          selector:@selector(reachabilityRunLoop)
                                                            object:nil];
        [self.reachabilityThread start];
    }
}

- (void)reachabilityRunLoop
{
    @autoreleasepool {
        NSString *PC_host = nil;
        //  Setting up the run loop
        BOOL moreWorkToDo = YES;
        BOOL exitNow = NO;
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        
        PC_host = [self trustedReachabilityAddress];
        
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
        // method "reachabilityChanged" will be called.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
        [Reachability sharedReachability].networkStatusNotificationsEnabled = YES;
        self.internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
        
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
        
        ReachabilityQuery *query = [[ReachabilityQuery alloc] init];
        query.hostNameOrAddress = PC_host;
        query.reachabilityRef = defaultRouteReachability;
        [query scheduleOnRunLoop:runLoop];
        
        // Add the exitNow BOOL to the thread dictionary.
        NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
        
        threadDict[@"ThreadShouldExitNow"] = @(exitNow);
        while (moreWorkToDo && !exitNow)
        {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            // Check to see if a delegate routine changed the exitNow value.
            exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
            if (exitNow) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNetworkReachabilityChangedNotification" object:nil];
                DLog(@"*** Exiting Reachablity loop");
            }
        }
        CFRelease(defaultRouteReachability);
        [self.reachabilityThread cancel];
        self.reachabilityThread = nil;
    }
}

/**
 This gets fired by a notification in a background thread but must run on main which is why we have the GCD code at the top
 **/
- (void)reachabilityChanged:(NSNotification*)notice
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reachabilityChanged:notice];
        });
        return;
    }
    
    self.internetConnectionStatus    = [[Reachability sharedReachability] internetConnectionStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:MBReachabilityChangeNotification object:nil];
    
    if (!self.networkFailureAlertWasDisplayed) {
        if (!self.networkIsReachable && (self.shouldDisplayOfflineAlert)) {
            NSString *title = nil;
            NSString *message = nil;
            self.networkFailureAlertWasDisplayed = YES;
            
            title = NSLocalizedString(@"Network Status",@"Title of alert message about network status");
            message = NSLocalizedString(
                                        @"You are currently offline, all data will be stored locally.  Please sync with ACGME later once you are back online.",
                                        @"Message to alert user of failed network status"
                                        );
            [self displayAlertWithTitle:title message:message];
            
        }
    }else{
        //ok looks like the network is trying to come back online
        //by now it has gone offline, and now trying to re-connect
        //however the reachability flag is giving us a false reading
        //because after testing we find reachabilityChanged gets called
        //more than once when a re-connect is underway, to work around
        //this we stall for 5 seconds using a timer, when it fires, then
        //we will determine if it is really time to declare ourselves
        //back online
        //
        //what was happening was that during the re-connect process, we
        //would get a bogus alert saying we were offline, we really
        //don't want any alert when re-connecting and this was the way
        //to address that annoying bogus alert
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(attemptingToReconnect:) userInfo:nil repeats:NO];
    }
}

- (void)suspendReachability
{
    if ([self.reachabilityThread threadDictionary]) {
        [self performSelector:@selector(reachabilityThreadShouldEnd) onThread:self.reachabilityThread withObject:nil waitUntilDone:YES];
    }
}

- (BOOL)networkIsReachable
{
    BOOL isReachable = self.internetConnectionStatus != NotReachable;
    
    return isReachable;
}

- (void)reachabilityThreadShouldEnd
{
    NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
    threadDict[@"ThreadShouldExitNow"] = @(YES);
}

/**
 This gets called by a timer, defined above, see comments above for more
 **/
- (void)attemptingToReconnect:(NSTimer*)timer
{
    if (self.networkIsReachable) {
        //setting this flag to allow another network disconnect alert to occur if it happens
        self.networkFailureAlertWasDisplayed = NO;
        
    }else{
        //must not be back on yet, try again in 1.25 seconds
        [NSTimer scheduledTimerWithTimeInterval:1.25 target:self selector:@selector(attemptingToReconnect:) userInfo:nil repeats:NO];
    }
    
}

- (NSString*)trustedReachabilityAddress
{
    return @"www.yahoo.com";
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

/**
 Return a context whose parent is managedObjectContext
 **/
- (NSManagedObjectContext*)childContext
{
    return [self childContextOfContext:[self managedObjectContext]];
}

/**
 Return a context whose parent is the arg context
 **/
- (NSManagedObjectContext*)childContextOfContext:(NSManagedObjectContext *)context
{
    @synchronized(self) {
        
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [childContext setParentContext:context];
        
        return childContext;
    }
    
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
