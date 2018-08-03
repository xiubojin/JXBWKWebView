//
//  InterceptURLHandler.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "InterceptURLHandler.h"
#import "WKMessageHandlerDispatch.h"

@implementation InterceptURLHandler

- (void)interceptURL:(NSURL *)URL {
    
    NSString *scheme = URL.scheme;
    
    if (scheme.length == 0) {
        return;
    }
    
    scheme = [scheme stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[scheme substringToIndex:1] uppercaseString]];
    
    NSString *targetName = scheme;
    
    NSString *actionName = URL.host;
    
    NSDictionary *param = [self parametersWithURL:URL];
    
    [[WKMessageHandlerDispatch sharedInstance] performTarget:targetName action:actionName params:param shouldCacheTarget:YES];
}

- (NSDictionary *)parametersWithURL:(NSURL *)URL {
    
    NSURLComponents *components = [NSURLComponents componentsWithString:[URL absoluteString]];
    
    //获取queryItem
    NSArray <NSURLQueryItem *> *queryItems = [components queryItems] ?: @[];
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in queryItems) {
        if (item.value == nil) {
            continue;
        }
        
        if (queryParams[item.name] == nil) {
            queryParams[item.name] = item.value;
        } else if ([queryParams[item.name] isKindOfClass:[NSArray class]]) {
            NSArray *values = (NSArray *)(queryParams[item.name]);
            queryParams[item.name] = [values arrayByAddingObject:item.value];
        } else {
            id existingValue = queryParams[item.name];
            queryParams[item.name] = @[existingValue, item.value];
        }
    }
    
    NSDictionary *params = queryParams.copy;
    
    return params;
}

@end
