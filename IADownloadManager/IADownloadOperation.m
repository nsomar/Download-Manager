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

@implementation IADownloadOperation
{
    BOOL executing;
    BOOL cancelled;
    BOOL finished;
}

+ (IADownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                            useCache:(BOOL)useCache
                                       progressBlock:(IAProgressBlock)progressBlock
                                     completionBlock:(IACompletionBlock)completionBlock
{
    IADownloadOperation *op = [IADownloadOperation new];
    op.url = url;
 
    if(useCache && [self hasCacheForURL:url])
    {
        [op fetchItemFromCacheForURL:url progressBlock:progressBlock
                       completionBlock:completionBlock];
        return nil;
    }
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"GET"
                                                        path:url.absoluteString
                                                  parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.operation = operation;
    
    __weak IADownloadOperation *weakOp = op;
    [op.operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         
         [IADownloadOperation setCacheWithData:responseObject url:url];
         __strong IADownloadOperation *StrongOp = weakOp;
         [StrongOp finish];
         completionBlock(YES, responseObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         __strong IADownloadOperation *StrongOp = weakOp;
         completionBlock(NO, nil);
         [StrongOp finish];
     }];
    
    [op.operation
     setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
         
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
