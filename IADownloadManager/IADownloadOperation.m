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
    IADownloadOperation *op = [IADownloadOperation new];
    op.url = url;
    op->_finalFilePath = filePath;
 
    if(useCache && [self hasCacheForURL:url])
    {
        [op fetchItemFromCacheForURL:url progressBlock:progressBlock
                       completionBlock:completionBlock];
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    if (filePath)
    {
        NSString *fname = [NSString stringWithFormat:@"tempDownload%d", arc4random_uniform(INT_MAX)];
        op->_tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fname];
        if ([[NSFileManager defaultManager] fileExistsAtPath:op->_tempFilePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:op->_tempFilePath error:nil];
        }
        operation.outputStream = [[NSOutputStream alloc] initToFileAtPath:op->_tempFilePath append:NO];
    }
    op.operation = operation;
    
    __weak IADownloadOperation *weakOp = op;
    [op.operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         
         [IADownloadOperation setCacheWithData:responseObject url:url];
         __strong IADownloadOperation *StrongOp = weakOp;
         if(StrongOp != nil && StrongOp->_tempFilePath && StrongOp->_finalFilePath)
         {
             NSError *error = nil;
             [[NSFileManager defaultManager] removeItemAtPath:StrongOp->_finalFilePath error:&error];
             [[NSFileManager defaultManager] moveItemAtPath:StrongOp->_tempFilePath toPath:StrongOp->_finalFilePath error:&error];
         }
         [StrongOp finish];
         completionBlock(YES, responseObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         __strong IADownloadOperation *StrongOp = weakOp;
         completionBlock(NO, nil);
         [StrongOp finish];
     }];
    
     [op.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
         
         float progress;
         
         if (totalBytesExpectedToRead == -1)
         {
             progress = -32;
         }
         else
         {
             progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
         }
         
         progressBlock(progress, url);
     }];
    
    return op;
}

- (void)start
{
    NSLog(@"opeartion for <%@> started.", _url);
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.operation start];
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
    unsigned char r[15];
    CC_MD5(str, (uint32_t)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (void)startOperation
{
    [self.operation start];
    executing = YES;
}

- (void)stop
{
    [self.operation cancel];
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
