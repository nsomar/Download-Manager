//
//  IASequentialDownloadHandler.h
//  DownloadManager
//
//  Created by Omar on 8/4/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASequentialDownloadManager.h"

@interface IASequentialDownloadHandler : NSObject

@property (nonatomic, strong) IASequentialProgressBlock progressBlock;
@property (nonatomic, strong) IASequentialCompletionBlock completionBlock;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, assign) int tag;
@property (nonatomic, weak) id<IASequentialDownloadManagerDelegate> delegate;

+ (IASequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                              progressBlock:(IASequentialProgressBlock)progressBlock
                                            completionBlock:(IASequentialCompletionBlock)completionBlock
                                                        tag:(int)tag;

+ (IASequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                                   delegate:(id<IASequentialDownloadManagerDelegate>)delegate;

- (int) indexOfURL:(NSURL*)url;
@end
