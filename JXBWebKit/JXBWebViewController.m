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
#import "InterceptURLHandler.h"
#import "JXBWKCustomProtocol.h"

#define kJXBScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kJXBScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
#define kJXBSafeAreaTopSpaceHeight  44
#define kJXBSafeAreaTopHeight       (kJXBScreenHeight == 812.0 ? 88 : 64)
#define kJXBSafeAreaBottomHeight    (kJXBScreenHeight == 812.0 ? 34 : 0)

static NSInteger const kContainerViewTag = 1000;
static NSString *POSTRequest = @"POST";

#pragma mark - MSWebViewController

@interface JXBWebViewController ()<WKNavigationDelegate, WKUIDelegate>
@property(nonatomic, strong) UIView                 *containerView;             //容器
@property(nonatomic, strong) UIProgressView         *progressView;              //进度条
@property(nonatomic, strong) UIBarButtonItem        *doneItem;                  //modal关闭item
@property(nonatomic, strong) UIBarButtonItem        *backNavLeftItem;           //back item
@property(nonatomic, strong) UIBarButtonItem        *closeNavLeftItem;          //close item
@property(nonatomic, assign) BOOL                   checkUrlCanOpen;            //检查url能否打开
@property(nonatomic, assign) BOOL                   showCloseNavLeftItem;       //是否展示关闭item
@property(nonatomic, assign) BOOL                   showBackNavLeftItemTitle;   //是否展示返回item标题
@property(nonatomic, assign) BOOL                   terminate;                  //WebView是否异常终止
@property(nonatomic, strong) NSMutableURLRequest    *request;                   //WebView入口请求
@end

@implementation JXBWebViewController

#pragma mark - 初始化
- (instancetype)initWithURLString:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url cookie:nil];
}

- (instancetype)initWithURL:(NSURL *)url cookie:(NSDictionary *)cookie {
    NSString *cookieStr = [JXBWKWebView cookieStringWithParam:cookie];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (cookieStr.length > 0) {
        [request addValue:cookieStr forHTTPHeaderField:@"Cookie"];
    }
    
    return [self initWithURLRequest:request.copy];
}

- (instancetype)initWithURLRequest:(NSURLRequest *)requst {
    _request = requst.mutableCopy;
    
    return [self init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    _timeoutInternal            = 60.0;
    _cachePolicy                = NSURLRequestReloadIgnoringCacheData;
    _allowsBFNavigationGesture  = NO;
    _showProgressView           = YES;
    _showCloseNavLeftItem       = YES;
    _showBackNavLeftItemTitle   = NO;
    _useCookieStorage           = NO;
    _needInterceptRequest       = NO;
    _terminate                  = NO;
    _backItemImgName            = @"back";
    _closeItemImgName           = @"close";
    
    //WebView
    _webView = [[JXBWKWebViewPool sharedInstance] getReusedWebViewForHolder:self];
    [_webView useExternalNavigationDelegate];
    [_webView setMainNavigationDelegate:self];
    _webView.UIDelegate = self;
    _webView.allowsBackForwardNavigationGestures = _allowsBFNavigationGesture;
    if (_showProgressView) {
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self registerSupportProtocolWithHTTP:NO schemes:@[@"post", kWKWebViewReuseScheme] protocolClass:[JXBWKCustomProtocol class]];
}

- (void)setAllowsBFNavigationGesture:(BOOL)allowsBFNavigationGesture {
    _allowsBFNavigationGesture = allowsBFNavigationGesture;
    _webView.allowsBackForwardNavigationGestures = allowsBFNavigationGesture;
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //监听设备方向
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (self.navigationController) {
        [_progressView removeFromSuperview];
    }
    
    UIDevice *device = [UIDevice currentDevice];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self sutupUI];
    
    [self fetchData];
}

- (void)deviceOrientationChanged:(NSNotification *)notification {
    [self updateNavigationItems];
}

#pragma mark - UI & Fetch Data
- (void)sutupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = self.backNavLeftItem;
    
    if (self.navigationController && [self.navigationController isBeingPresented]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked:)];
        
        _doneItem = doneButton;
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    UIView *containerView = [[UIView alloc] init];
    containerView.tag = kContainerViewTag;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.frame = CGRectMake(0, 0, kJXBScreenWidth, kJXBScreenHeight - kJXBSafeAreaBottomHeight - kJXBSafeAreaTopHeight);
    [self.view addSubview:containerView];
    
    _webView.frame = CGRectMake(0, 0, containerView.bounds.size.width, containerView.bounds.size.height);
    [containerView addSubview:_webView];
}

- (void)fetchData {
    !_request ? : [self loadURLRequest:_request];
}

- (void)clickLeftBarButtonItem {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backItem {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- KVO
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.navigationController && self.progressView.superview != self.navigationController.navigationBar && self.showProgressView) {
            [self updateFrameOfProgressView];
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
        [self updateTitleOfWebVC];
        [self updateNavigationItems];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - LoadRequest
- (void)loadURLRequest:(NSMutableURLRequest *)request {
    
    request.timeoutInterval = _timeoutInternal;
    request.cachePolicy = _cachePolicy;
    
    if (!_useCookieStorage) {
        if ([request.HTTPMethod isEqualToString:POSTRequest]) {
            [_webView clearBrowseHistory];
            [self loadPostRequest:request];
        }else{
            [_webView clearBrowseHistory];
            [_webView jxb_loadRequest:request.copy];
        }
    }else{
        NSString *validDomain = request.URL.host;
        
        if (validDomain.length <= 0) {
            [_webView clearBrowseHistory];
            [_webView jxb_loadRequest:request.copy];
        }else{
            [_webView clearBrowseHistory];
            NSString *cookie = [_webView cookieStringWithValidDomain:validDomain];
            [request addValue:cookie forHTTPHeaderField:@"Cookie"];
            [_webView jxb_loadRequest:request.copy];
        }
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

#pragma mark - NavigationItem
- (void)updateFrameOfProgressView {
    BOOL barHide = [self.navigationController isNavigationBarHidden];
    BOOL isIphoneX = kJXBScreenHeight == 812.0;
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGFloat barFrameYOnX = isIphoneX ? kJXBSafeAreaTopSpaceHeight : 0 ;
    CGRect barFrame = barHide ? CGRectMake(0, barFrameYOnX, navigationBarBounds.size.width, progressBarHeight) : CGRectMake(0, navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
    _progressView.frame = barFrame;
}

- (void)updateTitleOfWebVC {
    NSString *title = self.title;
    
    title = title.length > 0 ? title: _webView.title;
    
    self.navigationItem.title = title.length > 0 ? title : @"未经开发的星球~";
}

- (void)updateNavigationItems {
    if (_webView.canGoBack) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        if (self.showCloseNavLeftItem){
            [self.navigationItem setLeftBarButtonItems:@[self.backNavLeftItem, self.closeNavLeftItem] animated:NO];
        }else{
            [self.navigationItem setLeftBarButtonItems:@[self.backNavLeftItem] animated:NO];
        }
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.backNavLeftItem] animated:NO];
    }
}

- (UIBarButtonItem *)backNavLeftItem {
    if (_backNavLeftItem) return _backNavLeftItem;
    
    UIImage *backImage = [[UIImage imageNamed:_backItemImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    NSString *backBarButtonItemTitleString = self.showBackNavLeftItemTitle ? @"返回" : @"";
    if (_showBackNavLeftItemTitle) {
        NSDictionary *attr = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
        [backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:backBarButtonItemTitleString attributes:attr] forState:UIControlStateNormal];
        UIOffset offset = [[UIBarButtonItem appearance] backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        backButton.titleEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
        backButton.imageEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
        [backButton sizeToFit];
    } else {
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        backButton.frame = CGRectMake(0, 0, 40, 44);
    }
    
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setImage:backImage forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(navigationItemHandleBack:) forControlEvents:UIControlEventTouchUpInside];
    _backNavLeftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return _backNavLeftItem;
}

- (void)navigationItemHandleBack:(UIBarButtonItem *)sender {
    if ([_webView canGoBack]) {
        [self goBack];
        return;
    }
    
    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIBarButtonItem *)closeNavLeftItem {
    if (_closeNavLeftItem) return _closeNavLeftItem;
    if (self.navigationItem.rightBarButtonItem == _doneItem && self.navigationItem.rightBarButtonItem != nil) {
        _closeNavLeftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:_closeItemImgName] style:0 target:self action:@selector(doneButtonClicked:)];
    } else {
        _closeNavLeftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:_closeItemImgName] style:0 target:self action:@selector(navigationIemHandleClose:)];
    }
    return _closeNavLeftItem;
}

- (void)navigationIemHandleClose:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
        
        if (_interactiveType == WKNativeAndJSInteractiveTypeInterceptURL) {
            decisionHandler(WKNavigationActionPolicyCancel);
            
            //拦截URL进行处理
            if (_interactiveType == WKNativeAndJSInteractiveTypeInterceptURL) {
                if([self.interceptURLDelegate respondsToSelector:@selector(interceptURL:)]){
                    [self.interceptURLDelegate interceptURL:navigationAction.request.URL];
                }
            }
        }else{
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
        }
        
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self updateNavigationItems];
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [_delegate webViewControllerDidStartLoad:self];
    }
}

- (void)didFinishLoad{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self updateTitleOfWebVC];
    
    [self updateNavigationItems];
    
    if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
        [_delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)didFailLoadWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self updateTitleOfWebVC];
    
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

#pragma mark - 懒加载
- (UIView *)containerView {
    return [self.view viewWithTag:kContainerViewTag];
}

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_showProgressView) {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
    [_webView removeObserver:self forKeyPath:@"title"];
    
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
