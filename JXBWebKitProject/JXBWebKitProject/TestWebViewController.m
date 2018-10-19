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
        self.allowsBFNavigationGesture = YES;
        self.progressTintColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
