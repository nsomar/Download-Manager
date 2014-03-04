//
//  IADownloadManager.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IADownloadOperation;

typedef void (^IAProgressBlock)(float progress, NSURL *url);
typedef void (^IACompletionBlock)(BOOL success, id response);

@protocol IADownloadManagerDelegate <NSObject>
- (void) downloadManagerDidProgress:(float)progress;
- (void) downloadManagerDidFinish:(BOOL)success response:(id)response;
@end

@interface IADownloadManager : NSObject

//Start the download request for a URL, note that the same URL will never be downloaded twice
+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache;

//Start the download request for a URL and saving to a file, note that the same URL will never be downloaded twice
+ (void) downloadItemWithURL:(NSURL*)url
                    useCache:(BOOL)useCache
                  saveToPath:(NSString *)path;

//Delegate based events
// 1 url download operation can have multiple listeners
// But 1 listener cannot listen to 1 url download operation
+ (void) attachListener:(id<IADownloadManagerDelegate>)listener toURL:(NSURL*)url;

//Detach the listener from listening to more events,
//Please note that the url will still download
+ (void) detachListener:(id<IADownloadManagerDelegate>)listener;

//Block based events
//object param must be equal to self to ensure that 1 object can listen to only 1 download operation
+ (void) attachListenerWithObject:(id)object
                    progressBlock:(IAProgressBlock)progressBlock
                  completionBlock:(IACompletionBlock)completionBlock
                            toURL:(NSURL*)url;
//Remove listener
+ (void) detachObjectFromListening:(id)object;

+ (BOOL) isDownloadingItemWithURL:(NSURL*)url;
+ (void) stopDownloadingItemWithURL:(NSURL*)url;
+ (int) listenerCountForUrl:(NSURL *)url;

@end
