//
//  WKMessageHandlerDispatch.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WKMessageHandlerDispatch : NSObject

//全局唯一访问点
+ (instancetype)sharedInstance;

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;

@end
