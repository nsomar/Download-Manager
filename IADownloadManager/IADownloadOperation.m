//
//  IADownloadOperation.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IADownloadOperation.h"
#import "AFNetworking.h"
#import "IACacheManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation IADownloadOperation
{
    BOOL executing;
    BOOL cancelled;
    BOOL finished;
    NSString *_tempFilePath;
    NSString *_finalFilePath;
}

+ (IADownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                            useCache:(BOOL)useCache
                                            filePath:(NSString *)filePath
                                       progressBlock:(IAProgressBlock)progressBlock
                                     completionBlock:(IACompletionBlock)completionBlock
{
    IADownloadOperation *t = [IADownloadOperation new];
    t.url = url;
    t->_finalFilePath = filePath;
    
    if(useCache && [self hasCacheForURL:url])
    {
        [t fetchItemFromCacheForURL:url progressBlock:progressBlock
                    completionBlock:completionBlock];
        return nil;
    }
    __weak IADownloadOperation *weakT = t;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //
        float progress;
        
        progress = downloadProgress.fractionCompleted;
        
        progressBlock(progress, url);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //
        
        if (filePath)
        {
            /*
             NSString *fname = [NSString stringWithFormat:@"tempDownload%d", arc4random_uniform(INT_MAX)];
             t->_tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fname];
             if ([[NSFileManager defaultManager] fileExistsAtPath:t->_tempFilePath])
             {
             [[NSFileManager defaultManager] removeItemAtPath:t->_tempFilePath error:nil];
             }
             task.outputStream = [[NSOutputStream alloc] initToFileAtPath:t->_tempFilePath append:NO];
             */
            return [NSURL URLWithString:filePath];
        }
        else
        {
            NSString *fname = [NSString stringWithFormat:@"tempDownload%d", arc4random_uniform(INT_MAX)];
            t->_tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fname];
            if ([[NSFileManager defaultManager] fileExistsAtPath:t->_tempFilePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:t->_tempFilePath error:nil];
            }
            return [NSURL URLWithString:t->_tempFilePath];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //
        if(error)
        {
            __strong IADownloadOperation *StrongT = weakT;
            completionBlock(NO, nil);
            [StrongT finish];
        }
        else
        {
            [IADownloadOperation setCacheWithData:[NSData dataWithContentsOfFile:filePath.absoluteString] url:url];
            __strong IADownloadOperation *StrongT = weakT;
            if(StrongT != nil && StrongT->_tempFilePath && StrongT->_finalFilePath)
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:StrongT->_finalFilePath error:&error];
                [[NSFileManager defaultManager] moveItemAtPath:StrongT->_tempFilePath toPath:StrongT->_finalFilePath error:&error];
            }
            [StrongT finish];
            completionBlock(YES, [NSData dataWithContentsOfFile:filePath.absoluteString]);
        }
    }];
    
    
    
    t.task = task;
    
    
    
    return t;
}

- (void)start
{
    NSLog(@"opeartion for <%@> started.", _url);
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.task resume];
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

+ (BOOL)hasCacheForURL:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    return [IACacheManager hasObjectForKey:encodeKey];
}

- (void)fetchItemFromCacheForURL:(NSURL*)url
                   progressBlock:(IAProgressBlock)progressBlock
                 completionBlock:(IACompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *encodeKey = [IADownloadOperation cacheKeyForUrl:url];
        NSData *data = [IACacheManager objectForKey:encodeKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            progressBlock(1, url);
            completionBlock(YES, data);
            
            [self finish];
            
        });
    });
}

+ (void)setCacheWithData:(NSData*)data
                     url:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    [IACacheManager setObject:data forKey:encodeKey];
}

+ (NSString*)cacheKeyForUrl:(NSURL*)url
{
    NSString *key = url.absoluteString;
    const char *str = [key UTF8String];
    unsigned char r[16];
    CC_MD5(str, (uint32_t)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (void)startOperation
{
    [self.task resume];
    executing = YES;
}

- (void)stop
{
    [self.task cancel];
    cancelled = YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isCancelled
{
    return cancelled;
}

- (BOOL)isFinished
{
    return finished;
}

@end
