//
//  GoodListController.h
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/4.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WKMessageHandlerProtocol.h>

@interface GoodListController : UIViewController<WKMessageHandlerProtocol>
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, copy) void(^successCallback)(NSDictionary *result);
@property (nonatomic, copy) void(^failCallback)(NSDictionary *result);
@property (nonatomic, copy) void(^progressCallback)(NSDictionary *result);
@end
