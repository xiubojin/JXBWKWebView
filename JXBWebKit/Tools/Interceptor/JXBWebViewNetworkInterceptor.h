//
//  JXBWebViewNetworkInterceptor.h
//  JXBWebKitProject
//
//  Created by 金修博 on 2020/10/27.
//  Copyright © 2020 金修博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol JXBWebViewNetworkInterceptorDelegate <NSObject>

- (BOOL)shouldIntercept;

- (void)webViewNetworkInterceptorWithWebView:(WKWebView *)webView
             decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                             decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end


@interface JXBWebViewNetworkInterceptor : NSObject

@property (nonatomic, assign, readonly) BOOL shouldIntercept;

+ (instancetype)sharedInstance;

- (void)addDelegate:(id<JXBWebViewNetworkInterceptorDelegate>)delegate;
- (void)removeDelegate:(id<JXBWebViewNetworkInterceptorDelegate>)delegate;
- (void)handleInterceptorDataWithWebView:(WKWebView *)webView
         decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                         decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end
