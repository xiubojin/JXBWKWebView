//
//  WKMessageHandlerHelper.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKMessageHandlerHelper : NSObject

+ (void)callbackWithResult:(NSString *)result resultData:(NSDictionary *)resultData identifier:(NSString *)identifier message:(WKScriptMessage *)message;

@end
