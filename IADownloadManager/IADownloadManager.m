//
//  IADownloadManager.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IADownloadManager.h"
#import "IADownloadHandler.h"
#import "IADownloadOperation.h"

@interface IADownloadManager()

@property (nonatomic, strong) NSMutableDictionary *downloadOperations;
@property (nonatomic, strong) NSMutableDictionary *downloadHandlers;

- (void)removeHandlerWithTag:(int)tag;

@end

@implementation IADownloadManager

#pragma mark Initialization
#pragma mark -

+ (IADownloadManager*) instance
{
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.downloadOperations = [NSMutableDictionary new];
        self.downloadHandlers = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark Global Blocks
#pragma mark -

void (^globalProgressBlock)(float progress, NSURL *url, IADownloadManager* self) =
^(float progress, NSURL *url, IADownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(IADownloadHandler *handler, NSUInteger idx, BOOL *stop) {
        
        if(handler.progressBlock)
            handler.progressBlock(progress, url);
        
        if([handler.delegate respondsToSelector:@selector(downloadManagerDidProgress:)])
            [handler.delegate downloadManagerDidProgress:progress];
        
    }];
};

void (^globalCompletionBlock)(BOOL success, id response, NSURL *url, IADownloadManager* self) =
^(BOOL success, id response, NSURL *url, IADownloadManager* self)
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(IADownloadHandler *handler, NSUInteger idx, BOOL *stop) {
    
        if(handler.completionBlock)
            handler.completionBlock(success, response);
        
        if([handler.delegate respondsToSelector:@selector(downloadManagerDidFinish:response:)])
            [handler.delegate downloadManagerDidFinish:success response:response];
        
    }];
    
    //Remove the download handlers
    [self.downloadHandlers removeObjectForKey:url];
    
    //Remove the download operation
    [self.downloadOperations removeObjectForKey:url];
};

#pragma mark Entry Point
#pragma mark -

- (void) attachNewHandlerWithListener:(id<IADownloadManagerDelegate>)listener
                                toURL:(NSURL*)url
{
    //We should remove the old handler
    //Allow only 1 delegate to listen ot a set of URLs, maybe in the future we can have 1 delegate listening to more than a set of urls
    [self removeHandlerWithListener:listener];
    
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    
    if (!handlers)
        handlers = [NSMutableArray new];
    
    IADownloadHandler *handler = [IADownloadHandler downloadingHandlerWithURL:url
                                                                     delegate:listener];
    
    
    [handlers addObject:handler];
    [self.downloadHandlers setObject:handlers forKey:url];
}

- (void) attachNewHandlerWithProgressBlock:(IAProgressBlock)progressBlock
                           completionBlock:(IACompletionBlock)completionBlock
                                       tag:(int)tag
                                     toURL:(NSURL*)url
{
    //unlink the tag from the urls
    [self removeHandlerWithTag:tag];
    
    //Add the new handler
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (!handlers)
        handlers = [NSMutableArray new];
    
    IADownloadHandler *handler = [IADownloadHandler downloadingHandlerWithURL:url
                                                                progressBlock:progressBlock
                                                              completionBlock:completionBlock
                                                                          tag:tag];
    
    
    [handlers addObject:handler];

    [self.downloadHandlers setObject:handlers forKey:url];
}


#pragma mark Downloading
#pragma mark -

- (void)startDownloadOperation:(NSURL*)url
                      useCache:(BOOL)useCache
                    saveToPath:(NSString *)path
{
    if([self isDownloadingItemWithURL:url])
        return;
    
    IADownloadOperation *downloadingOperation = [IADownloadOperation
                                                 downloadingOperationWithURL:url
                                                 useCache:useCache
                                                 filePath:path
                                                 progressBlock:^(float progress, id x) {
                                                     
                                                     globalProgressBlock(progress, url, self);
                                                     
                                                 }
                                                 completionBlock:^(BOOL success, id response) {
                                                     
                                                     globalCompletionBlock(success, response, url, self);
                                                     
                                                 }];
    
    if(downloadingOperation)
    {
        [downloadingOperation start];
    
        //Add the new operation
        [self.downloadOperations setObject:downloadingOperation forKey:url];
    }
}

- (BOOL) isDownloadingItemWithURL:(NSURL*)url
{
    return [self.downloadOperations objectForKey:url] != nil;
}

#pragma mark IADownloadHandlers and IADownloadOperation Helpers
#pragma mark -

- (void)removeHandlerWithURL:(NSURL*)url tag:(int)tag
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (handlers)
    {
        for (int i = handlers.count - 1; i >= 0; i-- )
        {
            IADownloadHandler *handler = handlers[i];
            
            if (handler.tag == tag)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithURL:(NSURL*)url listener:(id)listener
{
    NSMutableArray *handlers = [self.downloadHandlers objectForKey:url];
    if (handlers)
    {
        for (int i = handlers.count - 1; i >= 0; i-- )
        {
            IADownloadHandler *handler = handlers[i];
            
            if (handler.delegate == listener)
            {
                [handlers removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithTag:(int)tag
{
    for (int i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (int j = array.count - 1; j >= 0; j-- )
        {
            IADownloadHandler *handler = array[j];
            if (handler.tag == tag)
            {
                [array removeObject:handler];
            }
        }
    }
}

- (void)removeHandlerWithListener:(id)listener
{
    for (int i = self.downloadHandlers.allKeys.count - 1; i >= 0; i-- )
    {
        id key = self.downloadHandlers.allKeys[i];
        NSMutableArray *array = [self.downloadHandlers objectForKey:key];
        
        for (int j = array.count - 1; j >= 0; j-- )
        {
            IADownloadHandler *handler = array[j];
            if (handler.delegate == listener)
            {
                [array removeObject:handler];
            }
        }
    }
}


#pragma mark Class Interface Memebers
#pragma mark -

+ (void) downloadItemWithURL:(NSURL*)url useCache:(BOOL)useCache
{
    [IADownloadManager downloadItemWithURL:url useCache:useCache saveToPath:nil];
}

+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
                  saveToPath:(NSString *)path
{
    [[self instance] startDownloadOperation:url useCache:useCache saveToPath:path];
}

+ (void) attachListener:(id<IADownloadManagerDelegate>)listener toURL:(NSURL*)url
{
    [[self instance] attachNewHandlerWithListener:listener toURL:url];
}

+ (void) detachListener:(id<IADownloadManagerDelegate>)listener;
{
    [[self instance] removeHandlerWithListener:listener];
}

+ (void) attachListenerWithObject:(id)object
                    progressBlock:(IAProgressBlock)progressBlock
                  completionBlock:(IACompletionBlock)completionBlock
                            toURL:(NSURL*)url

{
    [[self instance] attachNewHandlerWithProgressBlock:progressBlock
                                       completionBlock:completionBlock
                                                   tag:object ? (int)object : NSNotFound
                                                 toURL:url];
}

+ (void) detachObjectFromListening:(id)object
{
    [[self instance] removeHandlerWithTag:(int)object];
}

+ (BOOL) isDownloadingItemWithURL:(NSURL*)url
{
    return [[self instance] isDownloadingItemWithURL:url];
}

+ (void) stopDownloadingItemWithURL:(NSURL*)url
                             andTag:(int)tag
{
    [self.instance removeHandlerWithURL:url tag:tag];
    
    NSArray *handlers = [[self instance].downloadHandlers objectForKey:url];
    if (handlers.count == 0) {
        [self stopDownloadingItemWithURL:url];
    }
}

+ (void) stopDownloadingItemWithURL:(NSURL*)url
{
    [[[self instance].downloadOperations objectForKey:url] stop];
}

+ (int)listenerCountForUrl:(NSURL *)url
{
    NSMutableArray *handlers = [[self instance].downloadHandlers objectForKey:url];
    return handlers.count;
}

@end
