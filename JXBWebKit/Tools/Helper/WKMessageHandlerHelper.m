//
//  WKMessageHandlerHelper.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKMessageHandlerHelper.h"

@implementation WKMessageHandlerHelper

+ (void)callbackWithResult:(NSString *)result resultData:(NSDictionary *)resultData identifier:(NSString *)identifier message:(WKScriptMessage *)message {
    
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] initWithDictionary:resultData];
    resultDictionary[@"result"] = result;
    
    NSString *resultDataString = [self jsonStringWithData:resultDictionary];
    
    NSString *callbackString = [NSString stringWithFormat:@"window.Callback('%@', '%@', '%@')", identifier, result, resultDataString];
    
    if ([[NSThread currentThread] isMainThread]) {
        [message.webView evaluateJavaScript:callbackString completionHandler:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [message.webView evaluateJavaScript:callbackString completionHandler:nil];
        });
    }
}

+ (NSString *)jsonStringWithData:(NSDictionary *)data {
    NSString *messageJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:NULL] encoding:NSUTF8StringEncoding];;
    
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    return messageJSON;
}

@end
