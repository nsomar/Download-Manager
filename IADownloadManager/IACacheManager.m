//
//  IACacheManager.m
//  DownloadManager
//
//  Created by Omar on 8/7/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IACacheManager.h"
#import "EGOCache.h"

@interface IACacheManager()
@property (nonatomic, strong) NSMutableDictionary *memCache;
@end

@implementation IACacheManager

+ (IACacheManager*) instance
{
	static id instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] init];
	});
	
	return instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.memCache = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(lowMemory)
         name:UIApplicationDidReceiveMemoryWarningNotification
         object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    self.memCache = nil;
}

- (void) lowMemory
{
    self.memCache = nil;
}

+ (void) setObject:(id)object forKey:(NSString *)key
{
    if (object)
    {
        [self.instance.memCache setObject:object forKey:key];
        [[EGOCache globalCache] setObject:object forKey:key];
    }
    else
    {
        [self.instance.memCache removeObjectForKey:key];
        [[EGOCache globalCache] removeCacheForKey:key];
    }
}

+ (id) objectForKey:(NSString *)key
{
    id object = [self.instance.memCache objectForKey:key];
    
    if (!object) {
        object = [[EGOCache globalCache] objectForKey:key];
        [self.instance.memCache setObject:object forKey:key];
    }
    
    return object;
}

+ (BOOL) hasObjectForKey:(NSString *)key
{
    BOOL hasObject = [self.instance.memCache objectForKey:key] != nil;
    
    if (!hasObject) {
        hasObject = [[EGOCache globalCache] hasCacheForKey:key];
    }
    
    return hasObject;
}

@end
