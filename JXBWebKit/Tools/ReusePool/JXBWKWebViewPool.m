//
//  MSWKWebViewPool.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/17.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "JXBWKWebViewPool.h"
#import "JXBWKWebView.h"
#import "WKWebViewExtension.h"
#import "JXBWKCustomProtocol.h"

@interface JXBWKWebViewPool()
@property(nonatomic, strong, readwrite) dispatch_semaphore_t lock;
@property(nonatomic, strong, readwrite) NSMutableSet<__kindof JXBWKWebView *> *visiableWebViewSet;
@property(nonatomic, strong, readwrite) NSMutableSet<__kindof JXBWKWebView *> *reusableWebViewSet;
@end

@implementation JXBWKWebViewPool

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static JXBWKWebViewPool *webViewPool = nil;
    dispatch_once(&once,^{
        webViewPool = [[JXBWKWebViewPool alloc] init];
    });
    return webViewPool;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _visiableWebViewSet = [NSSet set].mutableCopy;
        _reusableWebViewSet = [NSSet set].mutableCopy;
        
        _lock = dispatch_semaphore_create(1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_clearReusableWebViews)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Public Method
- (__kindof JXBWKWebView *)getReusedWebViewForHolder:(id)holder{
    if (!holder) {
        #if DEBUG
        NSLog(@"MSWKWebViewPool must have a holder");
        #endif
        return nil;
    }
    
    [self _tryCompactWeakHolders];
    
    JXBWKWebView *webView;
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if (_reusableWebViewSet.count > 0) {
        webView = (JXBWKWebView *)[_reusableWebViewSet anyObject];
        [_reusableWebViewSet removeObject:webView];
        [_visiableWebViewSet addObject:webView];
        
        [webView webViewWillReuse];
    } else {
        webView = [[JXBWKWebView alloc] initWithFrame:CGRectZero];
        [_visiableWebViewSet addObject:webView];
    }
    webView.holderObject = holder;
    
    dispatch_semaphore_signal(_lock);
    
    return webView;
}

- (void)recycleReusedWebView:(__kindof JXBWKWebView *)webView{
    if (!webView) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if ([_visiableWebViewSet containsObject:webView]) {
        //将webView重置为初始状态
        [webView webViewEndReuse];
        
        [_visiableWebViewSet removeObject:webView];
        [_reusableWebViewSet addObject:webView];
        
    } else {
        if (![_reusableWebViewSet containsObject:webView]) {
            #if DEBUG
            NSLog(@"MSWKWebViewPool没有在任何地方使用这个webView");
            #endif
        }
    }
    dispatch_semaphore_signal(_lock);
}

- (void)cleanReusableViews{
    [self _clearReusableWebViews];
}

#pragma mark - Private Method
- (void)_tryCompactWeakHolders {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    NSMutableSet<JXBWKWebView *> *shouldreusedWebViewSet = [NSMutableSet set];
    
    for (JXBWKWebView *webView in _visiableWebViewSet) {
        if (!webView.holderObject) {
            [shouldreusedWebViewSet addObject:webView];
        }
    }
    
    for (JXBWKWebView *webView in shouldreusedWebViewSet) {
        [webView webViewEndReuse];
        
        [_visiableWebViewSet removeObject:webView];
        [_reusableWebViewSet addObject:webView];
    }
    
    dispatch_semaphore_signal(_lock);
}

- (void)_clearReusableWebViews {
    [self _tryCompactWeakHolders];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_reusableWebViewSet removeAllObjects];
    dispatch_semaphore_signal(_lock);
    
    [JXBWKWebView clearAllWebCache];
}

#pragma mark - Other
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
