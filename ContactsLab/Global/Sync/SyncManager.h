//
//  SyncManager.h
//  ClinicalTrials
//
//  Created by aarthur on 6/16/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GBSyncStudyOperationBlock)(BOOL, NSDictionary*);
@class Study;
@interface SyncManager : NSObject

+ (instancetype)sharedManager;
- (void)didCompleteOperation:(NSOperation*)operation;
- (void)loadOperationsFromDisk;
- (void)persistAllOperationsExcept:(NSOperation*)operation;

- (void)syncContactsWithCompltionBlock:(GBSyncStudyOperationBlock)block;

@end
