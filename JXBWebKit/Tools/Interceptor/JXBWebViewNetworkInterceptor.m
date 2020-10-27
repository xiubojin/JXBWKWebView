//
//  JXBWebViewNetworkInterceptor.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2020/10/27.
//  Copyright © 2020 金修博. All rights reserved.
//

#import "JXBWebViewNetworkInterceptor.h"

@interface JXBWebViewNetworkInterceptor ()
@property (nonatomic, strong) NSHashTable *delegates;
@end

@implementation JXBWebViewNetworkInterceptor

+ (instancetype)sharedInstance {
    static JXBWebViewNetworkInterceptor *interceptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interceptor = [[JXBWebViewNetworkInterceptor alloc] init];
    });
    return interceptor;
}

- (BOOL)shouldIntercept {
    BOOL shouldIntercept = NO;
    for (id<JXBWebViewNetworkInterceptorDelegate> delegate in self.delegates) {
        if (delegate.shouldIntercept) {
            shouldIntercept = YES;
            break;
        }
    }
    return shouldIntercept;
}


- (void)addDelegate:(id<JXBWebViewNetworkInterceptorDelegate>) delegate {
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<JXBWebViewNetworkInterceptorDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

- (void)handleInterceptorDataWithWebView:(WKWebView *)webView
         decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                         decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    for (id<JXBWebViewNetworkInterceptorDelegate> delegate in self.delegates) {
        [delegate webViewNetworkInterceptorWithWebView:webView
                       decidePolicyForNavigationAction:navigationAction
                                       decisionHandler:decisionHandler];
    }
}

#pragma mark - getter
- (NSHashTable *)delegates {
    if (_delegates == nil) {
        self.delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

@end
