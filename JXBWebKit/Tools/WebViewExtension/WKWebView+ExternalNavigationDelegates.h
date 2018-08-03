//
//  WKWebView+ExternalNavigationDelegates.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/17.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (ExternalNavigationDelegates)
@property(nonatomic, weak) id<WKNavigationDelegate> mainNavigationDelegate;

- (void)useExternalNavigationDelegate;
- (void)unUseExternalNavigationDelegate;
- (void)addExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)removeExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (BOOL)containsExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)clearExternalNavigationDelegates;
@end
