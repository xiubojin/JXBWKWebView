//
//  MSWKWebViewPool.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/17.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JXBWKWebView;

#define kWKWebViewReuseUrlString @"kwebkit://reuse-webView"
#define kWKWebViewReuseScheme    @"kwebkit"

@protocol MSWKWebViewReuseProtocol
- (void)webViewWillReuse;
- (void)webViewEndReuse;
@end

@interface JXBWKWebViewPool : NSObject

+ (instancetype)sharedInstance;

- (__kindof JXBWKWebView *)getReusedWebViewForHolder:(id)holder;

- (void)recycleReusedWebView:(__kindof JXBWKWebView *)webView;

- (void)cleanReusableViews;

@end
