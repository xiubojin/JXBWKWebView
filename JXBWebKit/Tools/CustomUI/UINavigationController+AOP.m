//
//  UINavigationController+AOP.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "UINavigationController+AOP.h"
#import <objc/runtime.h>

@interface UIGestureRecognizer (aopPopGesture)

@end

@implementation UIGestureRecognizer (aopPopGesture)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(@"_shouldBegin"));
//        Method swizzledMethod = class_getInstanceMethod(self, @selector(aop_gestureShouldBegin));
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    });
//}
//
//- (BOOL)aop_gestureShouldBegin {
//
//    BOOL shouldBegin = [self aop_gestureShouldBegin];
//
//    if (![self isMemberOfClass:NSClassFromString(@"UIScreenEdgePanGestureRecognizer")]) return shouldBegin;
//
//    UIResponder *nextViewController = self.view;
//    while (![nextViewController isKindOfClass:UIViewController.class]) {
//        nextViewController = nextViewController.nextResponder;
//    }
//
//    if ([nextViewController isKindOfClass:NSClassFromString(@"MSWebViewController")]) {
//        UIViewController *webController = (UIViewController *)nextViewController;
//
//        UINavigationController *navigationController = webController.navigationController;
//
//        if ([self.view isKindOfClass:NSClassFromString(@"WKContentView")]) {
//            if ([webController respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
//                return [(id<NavigationBackItemProtocol>)navigationController.topViewController navigationBar:navigationController.navigationBar shouldPopItem:navigationController.topViewController.navigationItem];
//            }
//        }
//    }
//
//    if ([nextViewController isKindOfClass:UINavigationController.class]) {
//        UINavigationController *navigationController = (UINavigationController *)nextViewController;
//
//        if ([navigationController.topViewController respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
//
//            return [(id<NavigationBackItemProtocol>)navigationController.topViewController navigationBar:navigationController.navigationBar shouldPopItem:navigationController.topViewController.navigationItem];
//        }
//    }
//
//    return shouldBegin;
//}

@end

@implementation UINavigationController (AOP)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method originalMethod = class_getInstanceMethod(self, @selector(navigationBar:shouldPopItem:));
//        Method swizzledMethod = class_getInstanceMethod(self, @selector(aop_navigationBar:shouldPopItem:));
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    });
//}
//
//- (BOOL)aop_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
//
//    BOOL shouldPopItemAfterPopViewController = [[self valueForKey:@"_isTransitioning"] boolValue];
//
//    if (shouldPopItemAfterPopViewController) {
//        return [self aop_navigationBar:navigationBar shouldPopItem:item];
//    }
//
//    UIViewController *viewController = [self topViewController];
//
//    if ([viewController respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
//
//        BOOL shouldPopItemAfterPopViewController = [(id<NavigationBackItemProtocol>)viewController navigationBar:navigationBar shouldPopItem:item];
//
//        if (shouldPopItemAfterPopViewController) {
//            return [self aop_navigationBar:navigationBar shouldPopItem:item];
//        }
//
//        [UIView animateWithDuration:0.25 animations:^{
//            [[self.navigationBar subviews] lastObject].alpha = 1;
//        }];
//
//        return shouldPopItemAfterPopViewController;
//    }
//
//    return [self aop_navigationBar:navigationBar shouldPopItem:item];
//}


@end

#pragma mark - NavigationBackItemProtocol
//- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
//    if ([self.navigationController.topViewController isKindOfClass:[MSWebViewController class]]) {
//        MSWebViewController* webVC = (MSWebViewController*)self.navigationController.topViewController;
//
//        if (webVC.webView.canGoBack) {
//            if (webVC.webView.isLoading) {
//                [webVC.webView stopLoading];
//            }
//
//            [webVC.webView goBack];
//
//            return NO;
//        } else {
//            if ([webVC.navigationItem.leftBarButtonItems containsObject:webVC.closeNavLeftItem]) {
//                [webVC updateNavigationItems];
//                return NO;
//            }
//            return YES;
//        }
//    }else{
//        return YES;
//    }
//}
