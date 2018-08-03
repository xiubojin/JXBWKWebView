//
//  WKMessageHandlerProtocol.h
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/20.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WKMessageHandlerProtocol <NSObject>

///JS传给Native的参数
@property (nonatomic, strong) NSDictionary *params;

/**
 Native业务处理成功的回调,result:回调给JS的数据
 */
@property (nonatomic, copy) void(^successCallback)(NSDictionary *result);

/**
 Native业务处理失败的回调,result:回调给JS的数据
 */
@property (nonatomic, copy) void(^failCallback)(NSDictionary *result);

/**
 Native业务处理的回调,result:回调给JS的数据
 */
@property (nonatomic, copy) void(^progressCallback)(NSDictionary *result);

@end
