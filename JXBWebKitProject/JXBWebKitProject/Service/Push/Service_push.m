//
//  Service_push.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/3.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "Service_push.h"
#import <UIKit/UIKit.h>

NSString * const kServicePushRegisterPushAuthority = @"kServicePushRegisterPushAuthority";

@implementation Service_push

//获取推送权限状态
- (void)func_getAuthorityState:(NSDictionary *)param {
    BOOL isOpen = NO;
    
    //iOS8.0以上
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types != UIUserNotificationTypeNone) {
        isOpen = YES;
    }
    
    void(^successCallback)(NSDictionary *result) = param[@"success"];
    
    NSDictionary *resultDict = @{@"isOpen":@(isOpen)};
    
    successCallback(resultDict);
}

//获取推送权限
- (void)func_getAuthority:(NSDictionary *)param {
    [self getAuthorityFromUser];
}

//延迟授权
- (void)getAuthorityFromUser {
    BOOL isOpen = NO;
    
    //iOS8.0以上
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types != UIUserNotificationTypeNone) {
        isOpen = YES;
    }
    
    if(isOpen) return;
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"获取推送权限提醒"
                                          message:@"我们想要访问您的推送权限以提供更好的服务,请在接下来的系统授权弹窗中点击\"确定\"按钮."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* denyAction = [UIAlertAction
                                 actionWithTitle:@"不"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
    
    UIAlertAction* allowAction = [UIAlertAction
                                  actionWithTitle:@"好的"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action) {
                                      [alertController dismissViewControllerAnimated:NO completion:nil];
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kServicePushRegisterPushAuthority object:nil];
                                      });
                                      
                                  }];
    
    [alertController addAction:denyAction];
    [alertController addAction:allowAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)func_openSystemNotifiPage:(NSDictionary *)param {
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"//prefs:root=NOTIFICATIONS_ID"]];
    }
}

@end
