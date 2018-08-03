//
//  WKWebView+ClearWebCache.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/10.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (ClearWebCache)

+ (void)clearAllWebCache;

- (void)clearBrowseHistory;

@end
