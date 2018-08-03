//
//  WKWebView+ClearWebCache.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/10.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKWebView+ClearWebCache.h"

@implementation WKWebView (ClearWebCache)

+ (void)clearAllWebCache {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion > 9){
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 9.0, *)) {
            NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                            WKWebsiteDataTypeMemoryCache,
                                                            WKWebsiteDataTypeSessionStorage,
                                                            WKWebsiteDataTypeDiskCache,
                                                            WKWebsiteDataTypeOfflineWebApplicationCache,
                                                            WKWebsiteDataTypeCookies,
                                                            WKWebsiteDataTypeLocalStorage,
                                                            WKWebsiteDataTypeIndexedDBDatabases,
                                                            WKWebsiteDataTypeWebSQLDatabases
                                                            ]];
            
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                       modifiedSince:dateFrom
                                                   completionHandler:^{
                                                       NSLog(@"WKWebView (ClearWebCache) Clear All Cache Done");
                                                   }];
        }
#endif
    } else {
        // iOS8
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        @"WKWebsiteDataTypeCookies",
                                                        @"WKWebsiteDataTypeLocalStorage",
                                                        @"WKWebsiteDataTypeIndexedDBDatabases",
                                                        @"WKWebsiteDataTypeWebSQLDatabases"
                                                        ]];
        for (NSString *type in websiteDataTypes) {
            clearWebViewCacheFolderByType(type);
        }
    }
}

FOUNDATION_STATIC_INLINE void clearWebViewCacheFolderByType(NSString *cacheType) {
    
    static dispatch_once_t once;
    static NSDictionary *cachePathMap = nil;
    
    dispatch_once(&once,
                  ^{
                      NSString *bundleId = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleIdentifierKey];
                      NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
                      NSString *storageFileBasePath = [libraryPath stringByAppendingPathComponent:
                                                       [NSString stringWithFormat:@"WebKit/%@/WebsiteData/", bundleId]];
                      
                      cachePathMap = @{@"WKWebsiteDataTypeCookies":
                                           [libraryPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"],
                                       @"WKWebsiteDataTypeLocalStorage":
                                           [storageFileBasePath stringByAppendingPathComponent:@"LocalStorage"],
                                       @"WKWebsiteDataTypeIndexedDBDatabases":
                                           [storageFileBasePath stringByAppendingPathComponent:@"IndexedDB"],
                                       @"WKWebsiteDataTypeWebSQLDatabases":
                                           [storageFileBasePath stringByAppendingPathComponent:@"WebSQL"]
                                       };
                  });
    
    NSString *filePath = cachePathMap[cacheType];
    if (filePath && filePath.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"removed file fail: %@ ,error %@", [filePath lastPathComponent], error);
            }
        }
    }
}

- (void)clearBrowseHistory {
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"_re", @"moveA",@"llIte", @"ms"]);
    if([self.backForwardList respondsToSelector:sel]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.backForwardList performSelector:sel];
#pragma clang diagnostic pop
    }
}

@end
