//
//  ContactsLabService.h
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsLabService : NSObject
@property (readwrite, copy)NSString * serviceAddress;

- (void)startServiceBlock:(void ( ^ ) (NSError*, NSData*))completionBlock;

@end
