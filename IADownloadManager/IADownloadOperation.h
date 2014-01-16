//
//  IADownloadOperation.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IADownloadManager.h"

@class AFHTTPRequestOperation;

@interface IADownloadOperation : NSOperation
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;

+ (IADownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                            useCache:(BOOL)useCache
                                            filePath:(NSString *)filePath
                                       progressBlock:(IAProgressBlock)progressBlock
                                     completionBlock:(IACompletionBlock)completionBlock;

- (void)start;
- (void)stop;

@end
