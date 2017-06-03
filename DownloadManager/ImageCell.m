//
//  ImageCell.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "ImageCell.h"
#import "AppDelegate.h"

@implementation ImageCell
{
    NSURL *url;
    NSArray *urls;
    UILabel *label;
    BOOL parallel;
}

- (void)stopDownloading
{
    if (parallel)
    {
#if USE_BLOCKS
        [IADownloadManager detachObjectFromListening:self];
#else
        [IADownloadManager detachListener:self];
#endif
    }
    else
    {
#if USE_BLOCKS
        [IASequentialDownloadManager detachObjectFromListening:self];
#else
        [IASequentialDownloadManager detachListener:self];
#endif
    }
}

- (void)setImageWithURLs:(NSArray*)urls_
{
    [self removeViews];
    [self setViewsForParallel:NO];
    
    UIImageView *imageView = (UIImageView*)[self viewWithTag:123321];
    imageView.image = nil;
    
    urls = urls_;

    [IASequentialDownloadManager downloadItemWithURLs:urls
                                             useCache:YES];

#if USE_BLOCKS
    [IASequentialDownloadManager attachListenerWithObject:self
                                            progressBlock:^(float progress, int index) {
                                                
                                                [self sequentialManagerProgress:progress
                                                                        atIndex:index];
                                                
                                            }
                                          completionBlock:^(BOOL success, id response, int index) {
                                              
                                              [self sequentialManagerDidFinish:success
                                                                      response:response
                                                                       atIndex:index];
                                              
                                          } toURLs:urls];
#else
    [IASequentialDownloadManager attachListener:self toURLs:urls];
#endif
}

- (void)setImageWithURL:(NSURL*)url_
{
    [self removeViews];
    [self setViewsForParallel:YES];
    
    UIImageView *imageView = (UIImageView*)[self viewWithTag:123321];
    imageView.image = nil;
    
    url = url_;
    
    [IADownloadManager downloadItemWithURL:url useCache:YES];
    
    //Use delegate or blocks to inform you of the progress
#if USE_BLOCKS
    [IADownloadManager attachListenerWithObject:self
                                  progressBlock:^(float progress, NSURL *url) {
                                      [self downloadManagerDidProgress:progress];
                                  }
                                completionBlock:^(BOOL success, id response) {
                                    [self downloadManagerDidFinish:success response:response];
                                } toURL:url];
#else
    [IADownloadManager attachListener:self toURL:url];
#endif
}

//Parallel download callbacks
- (void)downloadManagerDidFinish:(BOOL)success response:(id)response
{
    UIImageView *imageView = (UIImageView*)[self viewWithTag:123321];
    UIImage *image = [UIImage imageWithData:response];
    [imageView setImage:image];
}

- (void)downloadManagerDidProgress:(float)progress
{
    label.text = [NSString stringWithFormat:@"%f %%", progress * 100];
}

//Sequential download callbacks
- (void)sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(NSInteger)index
{
    NSInteger tag = 12332100 + index + 1;
    UIImageView *imageView = (UIImageView*)[self viewWithTag:tag];
    UIImage *image = [UIImage imageWithData:response];
    [imageView setImage:image];
}

- (void)sequentialManagerProgress:(float)progress atIndex:(NSInteger)index
{
    label.text = [NSString stringWithFormat:@"item %ld, %f %%", index, progress * 100];
}

- (void)setViewsForParallel:(BOOL)parallel_
{
    parallel = parallel_;
    if(parallel)
    {
        label = [[UILabel alloc] init];
        [self addSubview:label];
        label.frame = CGRectMake(40, 0, 280, 40);
        label.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        imageView.tag = 123321;
        imageView.frame = CGRectMake(0, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        label = [[UILabel alloc] init];
        [self addSubview:label];
        label.frame = CGRectMake(120, 0, 200, 40);
        label.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView;
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 12332101;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(0, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 12332102;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(40, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 12332103;
        [self addSubview:imageView];
        imageView.frame = CGRectMake(80, 0, 40, 40);
        imageView.backgroundColor = [UIColor clearColor];
    }
}

- (void)removeViews
{
    [label removeFromSuperview];
    UIImageView *imageView;
    imageView = (UIImageView*)[self viewWithTag:123321];
    [imageView removeFromSuperview];
    
    imageView = (UIImageView*)[self viewWithTag:12332101];
    [imageView removeFromSuperview];
    imageView = (UIImageView*)[self viewWithTag:12332102];
    [imageView removeFromSuperview];
    imageView = (UIImageView*)[self viewWithTag:12332103];
    [imageView removeFromSuperview];
    
}
@end
