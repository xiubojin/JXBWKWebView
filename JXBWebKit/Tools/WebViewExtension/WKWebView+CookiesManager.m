//
//  WKWebView+CookiesManager.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/10.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKWebView+CookiesManager.h"


@implementation WKWebView (CookiesManager)

- (void)writeCookie:(NSArray<NSHTTPCookie *> *)cookies completion:(dispatch_block_t)completion{
    if (cookies.count == 0) {
        completion();
        return;
    }
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
        //添加新的cookie
        [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [cookieStore setCookie:obj completionHandler:^{
                if (idx == cookies.count - 1) {
                    completion();
                }
            }];
        }];
    }else{
        [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:obj];
        }];
        [self reload];
        completion();
    }
}

@end
