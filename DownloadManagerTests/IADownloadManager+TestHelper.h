//
//  IADownloadManager+TestHelper.h
//  DownloadManager
//
//  Created by Omar on 3/4/14.
//  Copyright (c) 2014 InfusionApps. All rights reserved.
//

#import "IADownloadManager.h"

@interface IADownloadManager ()
@property (nonatomic, strong) NSMutableDictionary *downloadOperations;
@property (nonatomic, strong) NSMutableDictionary *downloadHandlers;

+ (IADownloadManager*) instance;
@end

@interface IADownloadManager (TestHelper)
@end