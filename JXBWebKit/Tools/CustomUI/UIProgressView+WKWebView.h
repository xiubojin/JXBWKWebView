//
//  UIProgressView+WKWebView.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/4.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXBWebViewController;

@interface UIProgressView (WKWebView)

@property(nonatomic, assign) BOOL hiddenWhenWebDidLoad;

@property(nonatomic, strong) JXBWebViewController *webViewController;

@end
