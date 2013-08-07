//
//  IACacheManager.h
//  DownloadManager
//
//  Created by Omar on 8/7/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IACacheManager : NSObject

+ (void) setObject:(id)object forKey:(NSString *)key;
+ (id) objectForKey:(NSString *)key;
+ (BOOL) hasObjectForKey:(NSString *)key;

@end
