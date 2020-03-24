//
//  WKWebView+SyncConfigUA.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/23.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <WebKit/WebKit.h>

typedef NS_ENUM (NSInteger, CustomUserAgentType){
    CustomUserAgentTypeReplace,     //替换所有UA
    CustomUserAgentTypeAppend,      //在原UA后面追加字符串
};


@interface WKWebView (SyncUserAgent)

/**
 *  设置UserAgent
 *
 *  @param type            replace or append original UA
 *  @param customUserAgent    customUserAgent
 */
- (void)syncCustomUserAgentWithType:(CustomUserAgentType)type
                    customUserAgent:(NSString *)customUserAgent;

@end
