//
//  AppManager.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKAppManager.h"
#import <objc/runtime.h>

static void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
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

#pragma mark - UINavigationController Category

@interface UINavigationController (Magical)

@end

@implementation UINavigationController (Magical)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        swizzleMethod(class, @selector(viewWillAppear:), @selector(aop_NavigationViewWillAppear:));
    });
}

- (void)aop_NavigationViewWillAppear:(BOOL)animation {
    [self aop_NavigationViewWillAppear:animation];
    
    [WKAppManager sharedInstance].currentNavigationController = self;
}

@end

#pragma mark - AppManager implementation

@implementation WKAppManager

+ (instancetype)sharedInstance {
    static WKAppManager *appManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        appManager = [[WKAppManager alloc] init];
    });
    
    return appManager;
}

@end
