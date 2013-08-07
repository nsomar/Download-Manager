//
//  ImageCell.h
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IADownloadManager.h"
#import "IASequentialDownloadHandler.h"

@interface ImageCell : UITableViewCell<IADownloadManagerDelegate, IASequentialDownloadManagerDelegate>

- (void)setImageWithURL:(NSURL*)url;
- (void)setImageWithURLs:(NSArray*)urls_;
- (void)stopDownloading;

@end
