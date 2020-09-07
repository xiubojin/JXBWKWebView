//
//  JXBWebViewController.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/4/28.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBWKWebView.h"
#import "WKWebViewExtension.h"
@class JXBWebViewController;

#ifndef JXB_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define JXB_REQUIRES_SUPER __attribute__((objc_requires_super))
#else
#define JXB_REQUIRES_SUPER
#endif
#endif

#pragma mark - MSWebViewControllerDelegate
@protocol JXBWebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerWillGoBack:(JXBWebViewController *)webViewController;
- (void)webViewControllerWillGoForward:(JXBWebViewController *)webViewController;
- (void)webViewControllerWillReload:(JXBWebViewController *)webViewController;
- (void)webViewControllerWillStop:(JXBWebViewController *)webViewController;
- (void)webViewControllerDidStartLoad:(JXBWebViewController *)webViewController;
- (void)webViewControllerDidFinishLoad:(JXBWebViewController *)webViewController;
- (void)webViewController:(JXBWebViewController *)webViewController didFailLoadWithError:(NSError *)error;

@end

#pragma mark - JXBWebViewController

@interface JXBWebViewController : UIViewController
@property (nonatomic, strong) JXBWKWebView                      *webView;
@property (nonatomic, weak)   id<JXBWebViewControllerDelegate>  delegate;
@property (nonatomic, strong) NSArray<NSHTTPCookie *>           *cookies;
@property (nonatomic, strong) UIColor                           *progressTintColor;
@property (nonatomic, strong) UIBarButtonItem                   *backItem;
@property (nonatomic, strong) UIBarButtonItem                   *closeItem;
@property (nonatomic, copy) NSURLRequest                        *request;
@property (nonatomic, copy) NSString                            *htmlString;
@property (nonatomic, copy) NSURL                               *fileURL;
@property (nonatomic, assign) BOOL                              showProgressView;
@property (nonatomic, assign) BOOL                              needInterceptRequest;
@property (nonatomic, assign) BOOL                              allowsBFNavigationGesture;
@property (nonatomic, assign) BOOL                              isRootController;
@property (nonatomic, readonly, getter=canGoBack)    BOOL       canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL       canGoForward;
@property (nonatomic, readonly, getter=isLoading)    BOOL       loading;

//初始化方法栈
- (instancetype)initWithURLString:(NSString *)urlString;
- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithURLRequest:(NSMutableURLRequest *)request;
- (instancetype)initWithHTMLString:(NSString *)htmlString;
- (instancetype)initWithFileURL:(NSURL *)fileURL;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadPostRequest:(NSURLRequest *)request;
- (void)updateNavigationTitle;
- (void)updateNavigationItems;

//当needInterceptRequest=YES时,该方法用于拦截请求
- (void)interceptRequestWithNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler;

//设置UserAgent
- (void)syncCustomUserAgentWithType:(CustomUserAgentType)type
                    customUserAgent:(NSString *)customUserAgent;

//注册拦截的scheme和class
- (void)registerSupportProtocolWithHTTP:(BOOL)supportHTTP
                                schemes:(NSArray<NSString *> *)schemes
                          protocolClass:(Class)protocolClass;

//注销拦截的scheme和class
- (void)unregisterSupportProtocolWithHTTP:(BOOL)supportHTTP
                                  schemes:(NSArray<NSString *> *)schemes
                            protocolClass:(Class)protocolClass;

//清除所有缓存
+ (void)clearAllWebCache;

@end

#pragma mark - JXBWebViewController (SubclassHooks)
//以下方法供子类调用
@interface JXBWebViewController (SubclassHooks)

//即将后退
- (void)willGoBack JXB_REQUIRES_SUPER;

//即将前进
- (void)willGoForward JXB_REQUIRES_SUPER;

//即将刷新
- (void)willReload JXB_REQUIRES_SUPER;

//即将结束
- (void)willStop JXB_REQUIRES_SUPER;

//开始加载
- (void)didStartLoad JXB_REQUIRES_SUPER;

//已经加载完成
- (void)didFinishLoad JXB_REQUIRES_SUPER;

//加载出错
- (void)didFailLoadWithError:(NSError *)error JXB_REQUIRES_SUPER;

@end
