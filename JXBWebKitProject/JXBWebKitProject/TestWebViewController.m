//
//  TestWebViewController.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/9/4.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "TestWebViewController.h"

@interface TestWebViewController ()

@end

@implementation TestWebViewController

- (instancetype)init {
    if (self = [super init]) {
        //允许侧滑返回
        self.allowsBFNavigationGesture = YES;
        //进度条颜色
        self.progressTintColor = [UIColor blackColor];
        //拦截每次请求的url
        self.needInterceptRequest = YES;
    }
    return self;
}

- (void)interceptRequestWithNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"当前加载的url:%@", navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Warning" style:0 target:self action:@selector(warningAcition)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)warningAcition {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}


@end
