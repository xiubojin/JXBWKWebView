//
//  MSWKWebView.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/17.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WKWebViewExtension.h"
#import "JXBWKWebViewPool.h"

@interface JXBWKWebView : WKWebView<JXBWKWebViewReuseProtocol>

@property (nonatomic, weak, readwrite) id holderObject;
@property (nonatomic, strong, readonly) NSDate *recycleDate;

+ (instancetype)webView;

+ (WKWebViewConfiguration *)defaultConfiguration;

#pragma mark - load request
- (void)jxb_loadRequestURLString:(NSString *)urlString;

- (void)jxb_loadRequestURL:(NSURL *)url;

- (void)jxb_loadRequestURL:(NSURL *)url cookie:(NSDictionary *)params;

- (void)jxb_loadRequest:(NSURLRequest *)requset;

- (void)jxb_loadHTMLTemplate:(NSString *)htmlTemplate;

#pragma mark - Cache
+ (void)jxb_clearAllWebCache;

#pragma mark - UserAgent
- (void)jxb_syncCustomUserAgentWithType:(CustomUserAgentType)type customUserAgent:(NSString *)customUserAgent;

#pragma mark - register intercept protocol
+ (void)jxb_registerProtocolWithHTTP:(BOOL)supportHTTP
               customSchemeArray:(NSArray<NSString *> *)customSchemeArray
                urlProtocolClass:(Class)urlProtocolClass;

+ (void)jxb_unregisterProtocolWithHTTP:(BOOL)supportHTTP
                  customSchemeArray:(NSArray<NSString *> *)customSchemeArray
                   urlProtocolClass:(Class)urlProtocolClass;

@end
