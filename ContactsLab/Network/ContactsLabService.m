//
//  ContactsLabService.m
//  ContactsLab
//
//  Created by aarthur on 6/13/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

#import "ContactsLabService.h"

@interface ContactsLabService() <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *urlSession;
@end

@implementation ContactsLabService

- (NSURLRequest*)request
{
    NSURLRequest *request;
    NSURL *webserviceURL = [NSURL URLWithString:self.serviceAddress];
    request = [[NSMutableURLRequest alloc] initWithURL:webserviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:6.0];
    return request;
}

- (void)startServiceBlock:(void ( ^ ) (NSError*, NSData*))completionBlock
{
    __weak __typeof(self)weakSelf = self;
    
    self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    [[self.urlSession dataTaskWithRequest:[self request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error) {
            completionBlock(error,nil);
        }else{
            completionBlock(nil,data);
        }
        strongSelf.urlSession = nil;
        
    }] resume];
    [self.urlSession finishTasksAndInvalidate];
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    self.urlSession = nil;
}

@end
