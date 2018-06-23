//
//  SyncOperation.m
//  ContactsLab
//
//  Created by aarthur on 6/22/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "SyncOperation.h"
#import "SyncManager.h"

#import "Company+CoreDataClass.h"
#import "Person+CoreDataClass.h"
#import "ContactsLabService.h"
#import "CoreDataUtility.h"
#import "Constants.h"

@interface SyncOperation()

@property (nonatomic, readwrite, getter=isFinished) BOOL so_finished;
@property (nonatomic, readwrite, getter=isExecuting) BOOL so_executing;

@end

@implementation SyncOperation

#pragma mark - Basic NSOperation Methods

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self init];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
}

- (void)main
{
    ContactsLabService *service;
    __block NSManagedObjectContext *ctx;
    
    [super main];

    dispatch_async(dispatch_get_main_queue(), ^{
        ctx = APP_DELEGATE.childContext;
    });

    service = [[ContactsLabService alloc] init];
    service.serviceAddress = SERVICE_ADDRESS;
    [service startServiceBlock:^(NSError *error, NSData *data) {
        if (!error && data) {
            
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray *contacts;
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
}

- (void)finishOperation
{
    [self setExecuting:NO];
    [self setFinished:YES];
    
    [[SyncManager sharedManager] didCompleteOperation:self];
    [[SyncManager sharedManager] persistAllOperationsExcept:self];
}

- (void)setExecuting:(BOOL)executing
{
    if (_so_executing != executing)
    {
        [self willChangeValueForKey:@"isExecuting"];
        _so_executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)setFinished:(BOOL)finished
{
    if (_so_finished != finished)
    {
        [self willChangeValueForKey:@"isFinished"];
        _so_finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (void)start
{
    if ([self isCancelled])
    {
        [self setFinished:YES];
        return;
    }
    
    [self setExecuting:YES];
    
    [self main];
}

- (BOOL)isConcurrent
{
    return YES;
}

@end
