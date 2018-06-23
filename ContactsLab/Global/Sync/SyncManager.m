//
//  SyncManager.m
//  ClinicalTrials
//
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import "SyncManager.h"
#import "CTBaseOperation.h"
#import "Constants.h"
#import "CoreDataUtility.h"
#import <MagicalRecord/MagicalRecord.h>
#import "SyncOperation.h"

@interface SyncManager()

@property (strong, nonatomic) NSOperationQueue *syncQueue;
@property (strong, nonatomic) GBSyncStudyOperationBlock completionBlock;

@end

@implementation SyncManager

+ (instancetype)sharedManager
{
    __strong static id instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] initPrivate];
    });
    
    return instance;
}

- (id)initPrivate
{
    self = [super init];
    
    if (self != nil)
    {
        self.syncQueue = [NSOperationQueue new];
        [self.syncQueue setMaxConcurrentOperationCount:1];
        [self.syncQueue setSuspended:!APP_DELEGATE.networkIsReachable];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStateChanged:) name:MBReachabilityChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)reachabilityStateChanged:(NSNotification*)notification
{
    BOOL isConnected = APP_DELEGATE.networkIsReachable;
    if (isConnected)
    {
        MRLogInfo(@"RESUMING SYNC QUEUE FOR REACHABILITY CHANGE");
        [self resumeSyncQueue];
    }
    else
    {
        MRLogInfo(@"PAUSING SYNC QUEUE FOR REACHABILITY CHANGE");
        [self pauseSyncQueue];
    }
}

#pragma mark - Queue Controls

- (void)handleNewlyAddedOperation
{
    [self persistAllOperations];
}

- (void)resumeSyncQueue
{
    if ([self.syncQueue isSuspended]) {
        [self.syncQueue setSuspended:NO];
    }
}

- (void)pauseSyncQueue
{
    [self.syncQueue setSuspended:YES];
    
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.completionBlock(NO, nil);
        });
    }
}

- (void)clearSyncQueue
{
    [self.syncQueue cancelAllOperations];
}

- (BOOL)isSyncQueueEmpty
{
    return ([self.syncQueue operationCount] == 0);
}

#pragma mark - Operation Finished

- (void)didCompleteOperation:(CTBaseOperation*)operation
{
    NSMutableArray *operations = [[self.syncQueue operations] mutableCopy];
    
    if ([operations containsObject:operation]) {
        MRLogInfo(@"did contain operation when finished");
        [operations removeObject:operation];
    }
    
    if ([operations count] == 0) {
        MRLogInfo(@"Operation is finishing. It is the only one left in the queue. Posting sync queue clear notification");
                
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GBSyncQueueDidClearNotification object:nil];
            
            if (self.completionBlock) {
                self.completionBlock(YES, ((operation.didFindData)?@{}:nil));
            }

        });
    }
}

#pragma mark - Operations

- (void)syncContactsWithCompltionBlock:(GBSyncStudyOperationBlock)block
{
    SyncOperation *operation;
    
    self.completionBlock = block;
    operation = [[SyncOperation alloc] init];
    [self.syncQueue addOperation:operation];
    [self handleNewlyAddedOperation];
    
    MRLogInfo(@"*** Operation started");
}

#pragma mark - Archive

- (NSString*)serializedOperationsFilePath
{
    return [Constants serializationFilePathComponent:@"operation_data"];
}

- (void)persistAllOperations
{
    MRLogInfo(@"Persisting operations");
    [self persistOperationsToDisk:[self.syncQueue operations]];
}

- (void)persistAllOperationsExcept:(NSOperation*)operation
{
    MRLogInfo(@"Persisting operations");
    NSMutableArray *operations = [[self.syncQueue operations] mutableCopy];
    
    if ([operations containsObject:operation]) {
        [operations removeObject:operation];
    }
    
    [self persistOperationsToDisk:operations];
}

- (void)persistOperationsToDisk:(NSArray*)operations
{
    BOOL success = [NSKeyedArchiver archiveRootObject:operations toFile:[self serializedOperationsFilePath]];
    
    if (success) {
        MRLogInfo(@"Successfully archived operations");
    }
    else {
        MRLogInfo(@"Failed to archive operations");
    }
}

- (void)loadOperationsFromDisk
{
    if ([self isSyncQueueEmpty] == NO) return;
    
    MRLogInfo(@"Loading operations from disk");
    NSArray *operations = [NSKeyedUnarchiver unarchiveObjectWithFile:[self serializedOperationsFilePath]];
    
    for (NSOperation *op in operations)
    {
        MRLogInfo(@"Adding %@ to queue", NSStringFromClass([op class]));
        [self.syncQueue addOperation:op];
    }
}


@end
