//
//  DownloadManagerTests.m
//  DownloadManagerTests
//
//  Created by Omar on 3/4/14.
//  Copyright (c) 2014 InfusionApps. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import "IADownloadManager.h"
#import "IADownloadManager+TestHelper.h"
#import "IADownloadOperation.h"

SPEC_BEGIN(DownloadManagerSpec)
__block NSURL *testURL;

beforeAll(^{
    testURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://pbs.twimg.com/profile_images/3006076564/1cd057de8ee11873efa2ac8d55a754f2_normal.jpeg"]];
});

describe(@"Downloading", ^{
    __block BOOL didFinishLoading;
   
    beforeEach(^{
        didFinishLoading = NO;
    });
    
    context(@"without cache", ^{
        
        it(@"should download a single file", ^{
            
            [IADownloadManager downloadItemWithURL:testURL useCache:NO];
            [IADownloadManager attachListenerWithObject:self
                                          progressBlock:^(float progress, NSURL *url) {
                                           
                                              
                                              
                                          }
                                        completionBlock:^(BOOL success, id response) {
                                            
                                            UIImage *image = [UIImage imageWithData:response];
                                            [[image should] beNonNil];
                                            [[image should] beKindOfClass:[UIImage class]];
                                            
                                            didFinishLoading = YES;
                                            
                                        } toURL:testURL];
            
            [[expectFutureValue(theValue(didFinishLoading))
              shouldEventuallyBeforeTimingOutAfter(20)] beTrue];
            
        });
        
        it(@"downloads can be stopped", ^{
            
            [IADownloadManager downloadItemWithURL:testURL useCache:NO];
            [IADownloadManager attachListenerWithObject:self
                                          progressBlock:^(float progress, NSURL *url) {
                                              
                                          }
                                        completionBlock:^(BOOL success, id response) {
                                            
                                            [[theValue(success) should] beFalse];
                                            didFinishLoading = YES;
                                            
                                        } toURL:testURL];
            
            BOOL isDownloadingFile = [IADownloadManager isDownloadingItemWithURL:testURL];
            
            [[theValue(isDownloadingFile) should] beTrue];
            
            [IADownloadManager stopDownloadingItemWithURL:testURL];
            
            [[expectFutureValue(theValue(didFinishLoading))
              shouldEventuallyBeforeTimingOutAfter(20)] beTrue];
        });
        
        it(@"should update the progress of the download", ^{
        
            __block BOOL didCallProgress = NO;
            
            [IADownloadManager downloadItemWithURL:testURL useCache:NO];
            [IADownloadManager attachListenerWithObject:self
                                          progressBlock:^(float progress, NSURL *url) {
                                              
                                              didCallProgress = YES;
                                              
                                          }
                                        completionBlock:^(BOOL success, id response) {
                                            
                                            didFinishLoading = YES;
                                            
                                        } toURL:testURL];
            
            [[expectFutureValue(theValue(didFinishLoading))
              shouldEventuallyBeforeTimingOutAfter(20)] beTrue];
            
            [[theValue(didCallProgress) should] beTrue];
            
        });
        
        it(@"shouldn't add the same download URL twice", ^{

            [IADownloadManager downloadItemWithURL:testURL useCache:NO];
            
            IADownloadManager *manager = [IADownloadManager instance];
            IADownloadOperation *operationBefore =
            [manager.downloadOperations objectForKey:testURL];

            
            [IADownloadManager downloadItemWithURL:testURL useCache:NO];
            IADownloadOperation *operationAfter =
            [manager.downloadOperations objectForKey:testURL];
            
            [[operationBefore should] equal:operationAfter];
        });
        
        it(@"shouldn't add the same handler for the same URL twice", ^{
            
            IADownloadManager *manager = [IADownloadManager instance];
            NSArray *array =
            [manager.downloadHandlers objectForKey:testURL];
            
            [[theValue(array.count) should] equal:@0];
            
            [IADownloadManager attachListenerWithObject:self
                                          progressBlock:nil
                                        completionBlock:nil
                                                  toURL:testURL];
            
            array =
            [manager.downloadHandlers objectForKey:testURL];
            [[theValue(array.count) should] equal:@1];
            
            [IADownloadManager attachListenerWithObject:self
                                          progressBlock:nil
                                        completionBlock:nil
                                                  toURL:testURL];
            
            array =
            [manager.downloadHandlers objectForKey:testURL];
            [[theValue(array.count) should] equal:@1];
            
            [IADownloadManager detachObjectFromListening:self];
        });
        
        it(@"should be able to add and remove a listener", ^{
            
            IADownloadManager *manager = [IADownloadManager instance];
            NSArray *array =
            [manager.downloadHandlers objectForKey:testURL];
            
            [[theValue(array.count) should] equal:@0];
            
            [IADownloadManager attachListenerWithObject:self
                                          progressBlock:nil
                                        completionBlock:nil
                                                  toURL:testURL];
            
            array =
            [manager.downloadHandlers objectForKey:testURL];
            [[theValue(array.count) should] equal:@1];
            
            [IADownloadManager detachObjectFromListening:self];
            
            array =
            [manager.downloadHandlers objectForKey:testURL];
            [[theValue(array.count) should] equal:@0];
            
        });
    });
});

SPEC_END