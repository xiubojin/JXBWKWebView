//
//  AppManager.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/7.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WKAppManager : NSObject

+ (instancetype)sharedInstance;

+ (__kindof UINavigationController *)currentNavigationController;

@end
