//
//  Service_Good.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/4.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "Service_Good.h"
#import "GoodListController.h"
#import "GoodDetailController.h"
#import <WKAppManager.h>

@implementation Service_Good

- (void)func_list:(NSDictionary *)params {
    GoodListController *vc = [[GoodListController alloc] init];
    vc.params = params[@"data"];
    vc.successCallback = params[@"success"];
    vc.failCallback = params[@"fail"];
    vc.progressCallback = params[@"progress"];
    [[WKAppManager sharedInstance].currentNavigationController pushViewController:vc animated:YES];
}

- (void)func_detail:(NSDictionary *)params {
    GoodDetailController *vc = [[GoodDetailController alloc] init];
    [[WKAppManager sharedInstance].currentNavigationController pushViewController:vc animated:YES];
}

@end
