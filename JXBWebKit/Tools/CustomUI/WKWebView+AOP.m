//
//  WKWebView+AOP.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/8.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKWebView+AOP.h"
#import <objc/runtime.h>


@implementation WKWebView (AOP)

+ (void)load {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    Class class = [self class];
    swizzleMethod(class, @selector(evaluateJavaScript:completionHandler:), @selector(aop_EvaluateJavaScript:completionHandler:));
#endif
}

- (void)aop_EvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler{
    id strongSelf = self;
    [self aop_EvaluateJavaScript:javaScriptString completionHandler:^(id r, NSError *e) {
        [strongSelf title];
        if (completionHandler) {
            completionHandler(r, e);
        }
    }];
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
