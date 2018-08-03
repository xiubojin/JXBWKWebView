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

//native与js交互方式
typedef NS_ENUM(NSUInteger, WKNativeAndJSInteractiveType) {
    WKNativeAndJSInteractiveTypeMessageHandler, //使用messageHandler(默认)
    WKNativeAndJSInteractiveTypeInterceptURL,   //使用拦截URL
};

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

#pragma mark - JXBWebViewControllerInterceptURLDelegate
@protocol JXBWebViewControllerInterceptURLProtocol <NSObject>

@required
- (void)interceptURL:(NSURL *)URL;

@end

#pragma mark - JXBWebViewController

@interface JXBWebViewController : UIViewController

/**
 交互行为相关,需要与H5交互时必须对该属性赋值
 interactiveType:指定原生与H5交互模式,使用MessageHandler或者拦截URL
 如果不给interceptURLDelegate和configuration赋值,将使用默认处理方式
 */
@property(nonatomic, assign) WKNativeAndJSInteractiveType interactiveType;

//拦截URL代理对象,不需要默认处理可自定义
@property(nonatomic, strong) id<JXBWebViewControllerInterceptURLProtocol> interceptURLDelegate;

//当前Web控件
@property(nonatomic, strong) JXBWKWebView                    *webView;

//是否展示进度条,默认YES
@property(nonatomic, assign) BOOL                           showProgressView;

//进度条的进度颜色
@property(nonatomic, strong) UIColor                        *progressTintColor;

//超时时间
@property(nonatomic, assign) NSTimeInterval                 timeoutInternal;

//Web缓存模式
@property(nonatomic, assign) NSURLRequestCachePolicy        cachePolicy;

//代理对象
@property(nonatomic, weak) id<JXBWebViewControllerDelegate>  delegate;

//是否可以goback
@property (nonatomic, readonly, getter=canGoBack) BOOL      canGoBack;

//是否可以goforward
@property (nonatomic, readonly, getter=canGoForward) BOOL   canGoForward;

//Web是否正在加载中
@property (nonatomic, readonly, getter=isLoading) BOOL      loading;

/**
 通过使用NSHTTPCookieStorage,根据URL Domain找到之前存储的cookie,进行加载.
 示例:使用AFN请求https://XX/login接口,获取到用户token等信息,要想在H5中使用这些token信息,要保证H5的URL的domain也是XX才行.否则获取不到.
 如果想在与NativeRequestApi域名不相同的H5 URL中使用Cookie,使用initWithCookieRequest:方法,自己拼接好cookie通过NSURLRequest加到header中.
 */
@property(nonatomic, assign) BOOL                           useCookieStorage;

//是否允许使用H5的侧滑返回手势,WebView复用的情况下默认为NO.
@property(nonatomic, assign) BOOL                           allowsBFNavigationGesture;

/**
 是否需要拦截请求,默认NO,如果设置为YES,则会将请求cancel,然后调用interceptRequestWithNavigationAction:方法
 
 如果有以下场景请将该属性设置为YES
 1.重新设置cookie
 2.给url追加参数
 */
@property(nonatomic, assign) BOOL                           needInterceptRequest;

//设置返回按钮的image
@property(nonatomic, copy) NSString                         *backItemImgName;

//设置关闭按钮的image
@property(nonatomic, copy) NSString                         *closeItemImgName;

#pragma mark - 初始化方法
- (instancetype)initWithURLString:(NSString *)urlString;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url cookie:(NSDictionary *)cookie;

- (instancetype)initWithURLRequest:(NSURLRequest *)requst;

//更新items
- (void)updateNavigationItems;

//注册拦截的scheme和class
- (void)registerSupportProtocolWithHTTP:(BOOL)supportHTTP
                                schemes:(NSArray<NSString *> *)schemes
                          protocolClass:(Class)protocolClass;

//注销拦截的scheme和class
- (void)unregisterSupportProtocolWithHTTP:(BOOL)supportHTTP
                                  schemes:(NSArray<NSString *> *)schemes
                            protocolClass:(Class)protocolClass;

//设置UserAgent
- (void)syncCustomUserAgentWithType:(CustomUserAgentType)type customUserAgent:(NSString *)customUserAgent;

- (void)loadHTMLTemplate:(NSString *)htmlTemplate;

//清除所有缓存
+ (void)clearAllWebCache;

@end

#pragma mark - JXBWebViewController (SubclassHooks)
//以下方法供子类调用
@interface JXBWebViewController (SubclassHooks)

/**
 如果needInterceptReq设置为YES,会调用该方法,为了保证流程可以正常执行,当needInterceptReq设置为YES时子类务必重写该方法
 
 @param navigationAction 通过该参数可以获取request和url,可以自行设置cookie或给url追加参数,然后让webView重新loadRequest
 */
- (void)interceptRequestWithNavigationAction:(WKNavigationAction *)navigationAction
                             decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

/*
 注意:子类调用以下方法需要在方法实现中调用super
 */

/**
 即将后退
 */
- (void)willGoBack JXB_REQUIRES_SUPER;

/**
 即将前进
 */
- (void)willGoForward JXB_REQUIRES_SUPER;

/**
 即将刷新
 */
- (void)willReload JXB_REQUIRES_SUPER;

/**
 即将结束
 */
- (void)willStop JXB_REQUIRES_SUPER;

/**
 开始加载
 */
- (void)didStartLoad JXB_REQUIRES_SUPER;

/**
 已经加载完成
 */
- (void)didFinishLoad JXB_REQUIRES_SUPER;

/**
 加载出错
 */
- (void)didFailLoadWithError:(NSError *)error JXB_REQUIRES_SUPER;

@end
