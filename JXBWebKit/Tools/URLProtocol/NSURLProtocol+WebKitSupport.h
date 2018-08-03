//
//  NSURLProtocol+WebKitSupport.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/3.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WebKitSupport)

+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;

@end
