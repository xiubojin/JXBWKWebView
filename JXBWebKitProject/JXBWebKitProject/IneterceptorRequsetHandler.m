//
//  IneterceptorRequsetHandler.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2020/10/27.
//  Copyright © 2020 金修博. All rights reserved.
//

#import "IneterceptorRequsetHandler.h"

@implementation IneterceptorRequsetHandler

- (BOOL)shouldIntercept {
    return YES;
}

- (void)webViewNetworkInterceptorWithWebView:(WKWebView *)webView
             decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                             decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"webView = %@", webView);
    
    NSLog(@"navigationAction.request = %@", navigationAction.request);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
