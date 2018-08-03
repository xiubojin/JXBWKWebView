//
//  WKWebView+SyncConfigUA.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/23.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKWebView+SyncUserAgent.h"

@implementation WKWebView (SyncUserAgent)

- (void)syncCustomUserAgentWithType:(CustomUserAgentType)type customUserAgent:(NSString *)customUserAgent {
    
    if (!customUserAgent || customUserAgent.length <= 0) {
        NSLog(@"WKWebView (SyncConfigUserAgent) config with invalid string");
        return;
    }
    
    if(type == CustomUserAgentTypeDefault){
        UIWebView *webView = [[UIWebView alloc] init];
        NSString *originalUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
        if (@available(iOS 9.0, *)) {
            self.customUserAgent = originalUserAgent;
        }else{
            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:originalUserAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
    }else if(type == CustomUserAgentTypeReplace){
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:customUserAgent, @"UserAgent", nil];
        if (@available(iOS 9.0, *)) {
            self.customUserAgent = customUserAgent;
        }else{
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
    }else if (type == CustomUserAgentTypeAppend){
        UIWebView *webView = [[UIWebView alloc] init];
        NSString *originalUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *appUserAgent = [NSString stringWithFormat:@"%@-%@", originalUserAgent, customUserAgent];
        
        if (@available(iOS 9.0, *)) {
            self.customUserAgent = appUserAgent;
        }else{
            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:appUserAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
    }else{
        NSLog(@"WKWebView (SyncConfigUA) config with invalid type :%@", @(type));
    }
}

@end
