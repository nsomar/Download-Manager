//
//  IADownloadHandler.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IADownloadManager.h"

@interface IADownloadHandler : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) IAProgressBlock progressBlock;
@property (nonatomic, strong) IACompletionBlock completionBlock;
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) id<IADownloadManagerDelegate> delegate;

+ (IADownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                   progressBlock:(IAProgressBlock)progressBlock
                                 completionBlock:(IACompletionBlock)completionBlock
                                             tag:(int)tag;

+ (IADownloadHandler*) downloadingHandlerWithURL:(NSURL*)url
                                        delegate:(id<IADownloadManagerDelegate>)delegate;
@end