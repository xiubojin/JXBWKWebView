//
//  WKCallNativeMethodMessageHandler.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKCallNativeMethodMessageHandler.h"
#import "WKMessageHandlerHelper.h"
#import "WKMessageHandlerDispatch.h"

@implementation WKCallNativeMethodMessageHandler

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //获取到js脚本传过来的参数
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:message.body];
    
    //获取callback的identifier
    NSString *identifier = params[@"identifier"];
    
    params[@"success"] = ^(NSDictionary *result){
        [WKMessageHandlerHelper callbackWithResult:@"success" resultData:result identifier:identifier message:message];
    };
    
    params[@"fail"] = ^(NSDictionary *result){
        [WKMessageHandlerHelper callbackWithResult:@"fail" resultData:result identifier:identifier message:message];
    };
    
    params[@"progress"] = ^(NSDictionary *result){
        [WKMessageHandlerHelper callbackWithResult:@"progress" resultData:result identifier:identifier message:message];
    };
    
    params[@"isFromH5"] = @(YES);
    params[@"webview"] = message.webView;
    
    NSString *targetName = params[@"targetName"];
    NSString *actionName = params[@"actionName"];
    
    if ([actionName isKindOfClass:[NSString class]] && actionName.length > 0) {
        [[WKMessageHandlerDispatch sharedInstance] performTarget:targetName action:actionName params:params shouldCacheTarget:YES];
    }
}

@end
