//
//  WKWebView+CookiesManager.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/10.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (CookiesManager)

+ (NSString *)cookieStringWithParam:(NSDictionary *)params;

- (NSString *)cookieStringWithValidDomain:(NSString *)validDomain;

- (NSString *)jsCookieStringWithValidDomain:(NSString *)validDomain;

@end
