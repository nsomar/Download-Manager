//
//  IASequentialDownloadHandler.m
//  DownloadManager
//
//  Created by Omar on 8/4/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IASequentialDownloadHandler.h"

@implementation IASequentialDownloadHandler

+ (IASequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                              progressBlock:(IASequentialProgressBlock)progressBlock
                                            completionBlock:(IASequentialCompletionBlock)completionBlock
                                                        tag:(int)tag
{
    IASequentialDownloadHandler *handler = [[IASequentialDownloadHandler alloc] init];
    
    handler.urls = urls;
    handler.progressBlock = progressBlock;
    handler.completionBlock = completionBlock;
    handler.tag = tag;
    
    return handler;
}

+ (IASequentialDownloadHandler*) downloadingHandlerWithURLs:(NSArray*)urls
                                                   delegate:(id<IASequentialDownloadManagerDelegate>)delegate
{
    IASequentialDownloadHandler *handler = [[IASequentialDownloadHandler alloc] init];
    
    handler.urls = urls;
    handler.delegate = delegate;
    
    return handler;
}

- (int) indexOfURL:(NSURL*)url
{
    __block int index;
    [self.urls enumerateObjectsUsingBlock:^(NSURL *blockURl, NSUInteger idx, BOOL *stop) {
        if([blockURl.absoluteString isEqualToString:url.absoluteString])
        {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}
@end
