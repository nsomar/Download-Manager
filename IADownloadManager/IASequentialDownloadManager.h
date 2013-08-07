//
//  IASequentialDownloadManager.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IASequentialProgressBlock)(float progress, int index);
typedef void (^IASequentialCompletionBlock)(BOOL success, id response, int index);

@protocol IASequentialDownloadManagerDelegate <NSObject>
- (void) sequentialManagerProgress:(float)progress atIndex:(int)index;
- (void) sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(int)index;
@end

@interface IASequentialDownloadManager : NSObject

//Start the download request for a sequence of URLs,
//note that the same sequence of URLs will never be downloaded twice
+ (void) downloadItemWithURLs:(NSArray*)urls
                     useCache:(BOOL)useCache;

//Delegate based events
// 1 set of URLs can have multiple listeners
// But 1 listener cannot listen to multiple URLs
+ (void) attachListener:(id<IASequentialDownloadManagerDelegate>)listener toURLs:(NSArray*)urls;

//Detach the listener from listening to more events,
//Please note that the URLs will still download
+ (void) detachListener:(id<IASequentialDownloadManagerDelegate>)listener;

//Block based events
//object param must be equal to self to ensure that 1 object can listen to only 1 download operation
+ (void) attachListenerWithObject:(id)object
                    progressBlock:(IASequentialProgressBlock)progressBlock
                  completionBlock:(IASequentialCompletionBlock)completionBlock
                           toURLs:(NSArray*)urls;

//Remove listener
+ (void) detachObjectFromListening:(id)object;

+ (BOOL) isDownloadingItemWithURLs:(NSArray*)urls;
+ (void) stopDownloadingItemWithURLs:(NSArray*)urls;

@end
