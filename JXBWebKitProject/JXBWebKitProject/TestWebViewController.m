//
//  TestWebViewController.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/9/4.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "TestWebViewController.h"
#import "IneterceptorRequsetHandler.h"

@interface TestWebViewController ()
@property (nonatomic, strong) IneterceptorRequsetHandler *handler;
@end

@implementation TestWebViewController

- (instancetype)init {
    if (self = [super init]) {
        //进度条颜色
        self.progressTintColor = [UIColor blackColor];
        //创建拦截器
        self.handler = [IneterceptorRequsetHandler new];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Test.webView = %@", self.webView);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Warning" style:0 target:self action:@selector(warningAcition)];

    [[JXBWebViewNetworkInterceptor sharedInstance] addDelegate:self.handler];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)warningAcition {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)dealloc {
    [[JXBWebViewNetworkInterceptor sharedInstance] removeDelegate:self.handler];
}

@end
