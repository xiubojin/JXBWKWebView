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
    
    //success callback
    params[@"success"] = ^(NSDictionary *result){
        [WKMessageHandlerHelper callbackWithResult:@"success" resultData:result identifier:identifier message:message];
    };
    
    //fail callback
    params[@"fail"] = ^(NSDictionary *result){
        [WKMessageHandlerHelper callbackWithResult:@"fail" resultData:result identifier:identifier message:message];
    };
    
    //progress callback
    params[@"progress"] = ^(NSDictionary *result){
        [WKMessageHandlerHelper callbackWithResult:@"progress" resultData:result identifier:identifier message:message];
    };
    
    //other mark
    params[@"isFromH5"] = @(YES);
    params[@"webview"] = message.webView;
    
    //把data包裹的数据重新添加到params里,然后将data删除,这样h5和native的target-action取值方式就统一了.
    NSDictionary *jsData = params[@"data"];
    if (jsData) {
        [params removeObjectForKey:@"data"];
        [jsData enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            [params setValue:value forKey:key];
        }];
    }
    
    //target-action
    NSString *targetName = params[@"targetName"];
    NSString *actionName = params[@"actionName"];
    
    if ([actionName isKindOfClass:[NSString class]] && actionName.length > 0) {
        [[WKMessageHandlerDispatch sharedInstance] performTarget:targetName action:actionName params:params shouldCacheTarget:YES];
    }
}

@end
