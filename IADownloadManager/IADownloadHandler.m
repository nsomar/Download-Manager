//
//  IADownloadHandler.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IADownloadHandler.h"

@implementation IADownloadHandler

+ (IADownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                   progressBlock:(IAProgressBlock)progressBlock
                                 completionBlock:(IACompletionBlock)completionBlock
                                             tag:(int)tag
{
    IADownloadHandler *handler = [IADownloadHandler new];
    handler.url = url;
    handler.tag = tag;
    handler.progressBlock = progressBlock;
    handler.completionBlock = completionBlock;
    
    return handler;
}

+ (IADownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                        delegate:(id<IADownloadManagerDelegate>)delegate
{
    IADownloadHandler *handler = [IADownloadHandler new];
    
    handler.url = url;
    handler.delegate = delegate;
    
    return handler;
}

@end