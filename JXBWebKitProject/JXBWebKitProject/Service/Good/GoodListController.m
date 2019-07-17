//
//  GoodListController.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/4.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "GoodListController.h"

@interface GoodListController ()
@property (nonatomic, strong) UIButton *btnSuccess;
@property (nonatomic, strong) UIButton *btnFail;
@property (nonatomic, strong) UIButton *btnProgress;
@end

@implementation GoodListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"商品列表";
    
    NSLog(@"param = %@",self.params);
    
    NSString *content = [self.params[@"content"]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self.btnFail = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnFail.frame = CGRectMake(0, 0, 100, 50);
    self.btnFail.center = self.view.center;
    [self.btnFail addTarget:self action:@selector(btnFailClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFail setTitle:@"fail" forState:UIControlStateNormal];
    
    self.btnSuccess = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnSuccess.frame = CGRectMake(CGRectGetMinX(self.btnFail.frame), CGRectGetMinY(self.btnFail.frame)-100, 100, 50);
    [self.btnSuccess addTarget:self action:@selector(btnSuccessClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSuccess setTitle:@"success" forState:UIControlStateNormal];
    
    self.btnProgress = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnProgress.frame = CGRectMake(CGRectGetMinX(self.btnFail.frame), CGRectGetMinY(self.btnFail.frame)+100, 100, 50);
    [self.btnProgress addTarget:self action:@selector(btnProgressClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnProgress setTitle:@"progress" forState:UIControlStateNormal];
    
    [self.view addSubview:self.btnSuccess];
    [self.view addSubview:self.btnFail];
    [self.view addSubview:self.btnProgress];
}

#pragma mark - event response
- (void)btnSuccessClick:(UIButton *)button {
    if (self.successCallback) {
        self.successCallback(@{
                               @"value":@"success result from GoodListController",
                               @"receivedData":self.params
                               });
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnFailClick:(UIButton *)button {
    if (self.failCallback) {
        self.failCallback(@{
                            @"value":@"fail result data from GoodDetailController",
                            @"receivedData":self.params
                            });
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnProgressClick:(UIButton *)button {
    if (self.progressCallback) {
        self.progressCallback(@{
                                @"value":@"60%...",
                                @"receivedData":self.params
                                });
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
