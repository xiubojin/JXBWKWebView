//
//  Service_setting.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/3.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "Service_setting.h"
#import <UIKit/UIKit.h>

@interface Service_setting()
@property(nonatomic, copy) NSString *cacheFilePath;
@end

@implementation Service_setting

//获取缓存大小
- (void)func_getCacheSize:(NSDictionary *)param {
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:self.cacheFilePath]) {
        // 目录下的文件计算大小
        NSArray *childrenFile = [manager subpathsAtPath:self.cacheFilePath];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [self.cacheFilePath stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
    }
    
    // 将大小转化为M,size单位b,转，KB,MB除以两次1024
    CGFloat sizeResult = size / 1024.0 / 1024.0;
    NSString *sizeStr = [NSString stringWithFormat:@"%.2fM",sizeResult];
    
    void(^successCallback)(NSDictionary *result) = param[@"success"];
    
    NSDictionary *resultDict = @{@"size":sizeStr};
    
    successCallback(resultDict);
}

//清除缓存
- (void)func_clearCache:(NSDictionary *)param {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.cacheFilePath]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:self.cacheFilePath];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [self.cacheFilePath stringByAppendingPathComponent:fileName];
            
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    
    void(^successCallback)(NSDictionary *result) = param[@"success"];
    
    successCallback(nil);
}

//缓存文件路径
- (NSString *)cacheFilePath {
    if (!_cacheFilePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES);
        _cacheFilePath = [paths lastObject];
    }
    
    return _cacheFilePath;
}

@end
