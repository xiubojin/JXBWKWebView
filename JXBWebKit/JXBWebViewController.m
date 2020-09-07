//
//  MSWebViewController.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/4/28.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <objc/runtime.h>
#import "JXBWebViewController.h"
#import "UIProgressView+WKWebView.h"
#import "JXBWKCustomProtocol.h"
typedef enum : NSUInteger {
    JXBWebViewLoadTypeNetRequest,    //网络请求
    JXBWebViewLoadTypeHTMLString,    //HTML模板
    JXBWebViewLoadTypeFile,          //文件路径
} JXBWebViewLoadType;

static NSString *POSTRequest = @"POST";

@interface JXBWebViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) UIView                 *containerView;
@property (nonatomic, strong) UIProgressView         *progressView;
@property (nonatomic, assign) BOOL                   checkUrlCanOpen;
@property (nonatomic, assign) BOOL                   terminate;
@property (nonatomic, assign) BOOL                   appeared;
@property (nonatomic, assign) JXBWebViewLoadType     loadType;
@end

@implementation JXBWebViewController

#pragma mark - Init
- (instancetype)initWithURLString:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURLRequest:[NSMutableURLRequest requestWithURL:URL]];
}

- (instancetype)initWithURLRequest:(NSMutableURLRequest *)request {
    if (self = [self init]) {
        _request = request;
        _loadType = JXBWebViewLoadTypeNetRequest;
    }
    return self;
}

- (instancetype)initWithHTMLString:(NSString *)htmlString {
    if (self = [self init]) {
        _htmlString = htmlString;
        _loadType = JXBWebViewLoadTypeHTMLString;
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    if (self = [self init]) {
        _fileURL = fileURL;
        _loadType = JXBWebViewLoadTypeFile;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _allowsBFNavigationGesture  = NO;
        _showProgressView           = YES;
        _needInterceptRequest       = NO;
        _terminate                  = NO;
        _webView = [[JXBWKWebViewPool sharedInstance] getReusedWebViewForHolder:self];
        [_webView useExternalNavigationDelegate];
        [_webView setMainNavigationDelegate:self];
        _webView.allowsBackForwardNavigationGestures = _allowsBFNavigationGesture;
        _webView.UIDelegate = self;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self sutupUI];
    [self fetchData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _webView.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController) {
        [_progressView removeFromSuperview];
    }
}

#pragma mark - UI & Fetch Data
- (void)sutupUI {
    _appeared = YES;
    self.navigationItem.leftBarButtonItem = _isRootController ? nil : self.backItem;
    if (_showProgressView) [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    [self registerSupportProtocolWithHTTP:NO schemes:@[@"post", kWKWebViewReuseScheme] protocolClass:[JXBWKCustomProtocol class]];
}

- (void)fetchData {
    if(!_request) return;
    [self.webView writeCookie:self.cookies completion:^{
        if (self.loadType == JXBWebViewLoadTypeNetRequest) {
            if(self.request) [self loadRequest:self.request];
        } else if (self.loadType == JXBWebViewLoadTypeHTMLString) {
            if (self.htmlString) [self.webView loadHTMLString:self.htmlString baseURL:nil];
        } else if (self.loadType == JXBWebViewLoadTypeFile) {
            if (self.fileURL) {
                if (@available(iOS 9.0, *)) {
                    [self.webView loadFileURL:self.fileURL allowingReadAccessToURL:nil];
                }
            }
        }
    }];
}

#pragma mark- KVO
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.navigationController && self.progressView.superview != self.navigationController.navigationBar && self.showProgressView) {
            [self _updateFrameOfProgressView];
            if (![self.navigationController isNavigationBarHidden]) {
                [self.navigationController.navigationBar addSubview:self.progressView];
            }else{
                [_webView addSubview:self.progressView];
            }
        }
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (progress >= _progressView.progress) {
            [_progressView setProgress:progress animated:YES];
        } else {
            [_progressView setProgress:progress animated:NO];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        [self updateNavigationTitle];
        [self updateNavigationItems];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - LoadRequest
- (void)loadRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod isEqualToString:POSTRequest]) {
        [_webView clearBrowseHistory];
        [self loadPostRequest:request.mutableCopy];
    }else{
        [_webView clearBrowseHistory];
        [_webView jxb_loadRequest:request];
    }
}

- (void)loadPostRequest:(NSMutableURLRequest *)request {
    NSString *cookie = request.allHTTPHeaderFields[@"Cookie"];
    NSString *scheme = request.URL.scheme;
    NSData *requestData = request.HTTPBody;
    NSMutableString *urlString = [NSMutableString stringWithString:request.URL.absoluteString];
    NSRange schemeRange = [urlString rangeOfString:scheme];
    [urlString replaceCharactersInRange:schemeRange withString:@"post"];
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *bodyStr  = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
    [newRequest setValue:bodyStr forHTTPHeaderField:@"bodyParam"];
    [newRequest setValue:scheme forHTTPHeaderField:@"oldScheme"];
    [newRequest addValue:cookie forHTTPHeaderField:@"Cookie"];
    [_webView jxb_loadRequest:newRequest.copy];
}

#pragma mark - NavigationBar
- (void)_updateFrameOfProgressView {
    BOOL barHide = [self.navigationController isNavigationBarHidden];
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat isX = (screenHeight == 812.f || screenHeight == 896.f) ? YES : NO;
    CGFloat barFrameYOnX = isX ? 44.f : 0 ;
    CGRect barFrame = barHide ? CGRectMake(0, barFrameYOnX, navigationBarBounds.size.width, progressBarHeight) : CGRectMake(0, navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
    _progressView.frame = barFrame;
}

//更新页面title
- (void)updateNavigationTitle {
    NSString *title = self.title;
    title = title.length > 0 ? title : [self.webView title];
    self.navigationItem.title = title;
}

//更新leftNavItems
- (void)updateNavigationItems {
    if (self.webView.canGoBack) {
        if (_isRootController) {
            self.navigationItem.leftBarButtonItems = @[self.backItem];
        } else {
            self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
        }
    } else {
        if (_isRootController) {
            self.navigationItem.leftBarButtonItems = nil;
        } else {
            self.navigationItem.leftBarButtonItems = @[self.backItem];
        }
    }
}

//返回item
- (UIBarButtonItem *)backItem {
    if (_backItem) return _backItem;
    UIImage *backImage = [self _readImageWithName:@"webView_back"];
    _backItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(backItemClick:)];
    return _backItem;
}

//关闭item
- (UIBarButtonItem *)closeItem {
    if (_closeItem) return _closeItem;
    UIImage *closeImage = [self _readImageWithName:@"webView_close"];
    _closeItem = [[UIBarButtonItem alloc] initWithImage:closeImage
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(closeItemClick:)];
    return _closeItem;
}

- (UIImage *)_readImageWithName:(NSString *)imageNamed {
    NSBundle *bundle = [NSBundle bundleForClass:[JXBWebViewController class]];
    NSURL *URL = [bundle URLForResource:@"JSResources" withExtension:@"bundle"];
    NSBundle *curBundle = [NSBundle bundleWithURL:URL];
    return [UIImage imageNamed:imageNamed inBundle:curBundle compatibleWithTraitCollection:nil];
}

- (void)backItemClick:(UIBarButtonItem *)sender {
    if ([self.webView canGoBack]) {
        [self goBack];
        return;
    }
    
    [self handleNavigation];
}

- (void)closeItemClick:(UIBarButtonItem *)sender {
    [self handleNavigation];
}

- (void)handleNavigation {
    if (self.navigationController.presentingViewController && self.navigationController.childViewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - WKNavigationDelegate
//发送请求之前决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    
    if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/'"] evaluateWithObject:components.URL.absoluteString]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString]) {
        
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            if (@available(iOS 10.0, *)) {
                [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
            } else {
                [[UIApplication sharedApplication] openURL:components.URL];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about' OR SELF MATCHES[cd] 'post'"] evaluateWithObject:components.scheme]) {
        if (@available(iOS 8.0, *)) { // openURL if ios version is low then 8 , app will crash
            if (!self.checkUrlCanOpen || [[UIApplication sharedApplication] canOpenURL:components.URL]) {
                if (@available(iOS 10.0, *)) {
                    [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
                } else {
                    [[UIApplication sharedApplication] openURL:components.URL];
                }
            }
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
                [[UIApplication sharedApplication] openURL:components.URL];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    [self updateNavigationItems];
    
    //是否需要拦截请求
    if (_needInterceptRequest) {
        [self interceptRequestWithNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)interceptRequestWithNavigationAction:(WKNavigationAction *)navigationAction
                             decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyCancel);
}

//在收到响应后，决定是否跳转(表示当客户端收到服务器的响应头，根据response相关信息，可以决定这次跳转是否可以继续进行。)
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self didStartLoad];
}

//接收到服务器跳转请求之后调用(接收服务器重定向时)
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    //...
}

//加载失败时调用(加载内容时发生错误时)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        // [webView reloadFromOrigin];
        return;
    }
    [self didFailLoadWithError:error];
}

//当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    //...
}

//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self didFinishLoad];
}

//导航期间发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self didFailLoadWithError:error];
}

//iOS9.0以上异常终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    _terminate = YES;
    [webView reload];
}

#pragma mark - WKNavigationDelegate - 为子类提供的WKWebViewDelegate方法,使用时一定要调用super方法!
- (void)willGoBack{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillGoBack:)]) {
        [_delegate webViewControllerWillGoBack:self];
    }
}

- (void)willGoForward{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillGoForward:)]) {
        [_delegate webViewControllerWillGoForward:self];
    }
}

- (void)willReload{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillReload:)]) {
        [_delegate webViewControllerWillReload:self];
    }
}

- (void)willStop{
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillStop:)]) {
        [_delegate webViewControllerWillStop:self];
    }
}

- (void)didStartLoad{
    [self updateNavigationItems];
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [_delegate webViewControllerDidStartLoad:self];
    }
}

- (void)didFinishLoad{
    [self updateNavigationTitle];
    [self updateNavigationItems];
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
        [_delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)didFailLoadWithError:(NSError *)error{
    [self updateNavigationTitle];
    [self updateNavigationItems];
    if (_delegate && [_delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
        [_delegate webViewController:self didFailLoadWithError:error];
    }
    [_progressView setProgress:0.9 animated:YES];
}

#pragma mark - WKWebViewUIDelegate
// 提示框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIViewController *vc = [self viewController];
    if (vc && vc.isViewLoaded && _webView && [_webView superview]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completionHandler();
        }]];
        [vc presentViewController:alert animated:YES completion:NULL];
    }else{
        completionHandler();
    }
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIViewController *vc = [self viewController];
    if (vc && vc.isViewLoaded && _webView && [_webView superview]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(YES);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(NO);
        }]];
        [vc presentViewController:alert animated:YES completion:NULL];
    }else{
        completionHandler(NO);
    }
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIViewController *vc = [self viewController];
    if (vc && vc.isViewLoaded && _webView && [_webView superview]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:prompt ? prompt : @"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.textColor = [UIColor blackColor];
            textField.placeholder = defaultText ? defaultText : @"";
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler([[alert.textFields lastObject] text]);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(nil);
        }]];
        [vc presentViewController:alert animated:YES completion:NULL];
    }else{
        completionHandler(nil);
    }
}

- (UIViewController*)viewController{
    for (UIView* next = [_webView superview]; next; next = next.superview){
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

#pragma mark - goBack & goForward
- (BOOL)isLoading{
    return _webView.isLoading;
}

- (BOOL)canGoBack{
    return _webView.canGoBack;
}

- (BOOL)canGoForward{
    return _webView.canGoForward;
}

- (void)goBack {
    [self willGoBack];
    [_webView goBack];
}

- (void)reload {
    [self willReload];
    [_webView reload];
}

- (void)forward {
    [self willGoForward];
    [_webView goForward];
}

- (void)stopLoading {
    [self willStop];
    [_webView stopLoading];
}

#pragma mark - setter
- (void)setAllowsBFNavigationGesture:(BOOL)allowsBFNavigationGesture {
    _allowsBFNavigationGesture = allowsBFNavigationGesture;
    _webView.allowsBackForwardNavigationGestures = allowsBFNavigationGesture;
}

#pragma mark - getter
- (UIProgressView *)progressView {
    if (_progressView) return _progressView;
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.trackTintColor = [UIColor clearColor];
    _progressView.progressTintColor = _progressTintColor ? _progressTintColor : [UIColor orangeColor];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.hiddenWhenWebDidLoad = YES;
    __weak typeof(self) weakSelf = self;
    _progressView.webViewController = weakSelf;
    return _progressView;
}

#pragma mark - Ohter Method
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    if (_appeared) {
        if (_showProgressView) [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView removeObserver:self forKeyPath:@"title"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (!_terminate) {
        [[JXBWKWebViewPool sharedInstance] recycleReusedWebView:_webView];
    }
}

+ (void)clearAllWebCache {
    [JXBWKWebView jxb_clearAllWebCache];
}

- (void)registerSupportProtocolWithHTTP:(BOOL)supportHTTP
                                schemes:(NSArray<NSString *> *)schemes
                          protocolClass:(Class)protocolClass {
    [JXBWKWebView jxb_registerProtocolWithHTTP:supportHTTP
                             customSchemeArray:schemes
                              urlProtocolClass:protocolClass];
}

- (void)unregisterSupportProtocolWithHTTP:(BOOL)supportHTTP
                                  schemes:(NSArray<NSString *> *)schemes
                            protocolClass:(Class)protocolClass {
    [JXBWKWebView jxb_unregisterProtocolWithHTTP:supportHTTP
                               customSchemeArray:schemes
                                urlProtocolClass:protocolClass];
}

- (void)syncCustomUserAgentWithType:(CustomUserAgentType)type customUserAgent:(NSString *)customUserAgent {
    [_webView jxb_syncCustomUserAgentWithType:type customUserAgent:customUserAgent];
}

- (void)loadHTMLTemplate:(NSString *)htmlTemplate {
    [_webView jxb_loadHTMLTemplate:htmlTemplate];
}

@end
