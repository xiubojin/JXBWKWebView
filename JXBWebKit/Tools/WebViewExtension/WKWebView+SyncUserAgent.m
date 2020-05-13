//
//  WKWebView+SyncConfigUA.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/23.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKWebView+SyncUserAgent.h"

@implementation WKWebView (SyncUserAgent)

- (void)syncCustomUserAgentWithType:(CustomUserAgentType)type
                    customUserAgent:(NSString *)customUserAgent {
    
    if (!customUserAgent || customUserAgent.length <= 0) {
        return;
    }
    
    if(type == CustomUserAgentTypeReplace){
        if (@available(iOS 9.0, *)) {
            self.customUserAgent = customUserAgent;
        }
    }else if (type == CustomUserAgentTypeAppend){
        [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id userAgent, NSError * _Nullable error) {
            if ([userAgent isKindOfClass:[NSString class]]) {
                NSString *newUserAgent = [NSString stringWithFormat:@"%@-%@", userAgent, customUserAgent];
                if (@available(iOS 9.0, *)) {
                    self.customUserAgent = newUserAgent;
                }
            }
        }];
    }else{
        NSLog(@"WKWebView (SyncConfigUA) config with invalid type :%@", @(type));
    }
}

@end
