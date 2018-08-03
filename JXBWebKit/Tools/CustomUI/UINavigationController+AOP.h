//
//  UINavigationController+AOP.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^NavigationItemPopHandler)(UINavigationBar *navigationBar, UINavigationItem *navigationItem);

@protocol NavigationBackItemProtocol <NSObject>

@optional
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;

@end


/**
 该分类为解决采用系统导航返回按钮的WebViewController提供hook_pop操作
 自定义NaviagationController不需要该方案,避免不必要的hook操作将.m文件代码注释掉.
 如果需要系统样式的导航栏,可将.m文件注释代码打开,将pragma - NavigationBackItemProtocol代码块的代码copy到MSWebViewController.m中.
 
 实现说明:
 UINavigationController (HookPopEvent) 为获取用户点击系统返回按钮时的pop操作
 UIGestureRecognizer (HookPopGesture) 为获取用户侧滑手势的pop操作
 hook住上面两个操作后,会通过NavigationBackItemProtocol协议的delegate方法让delegate对象执行某些操作,比如更新NavigationBarButtonItem
 */
@interface UINavigationController (AOP)<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end
