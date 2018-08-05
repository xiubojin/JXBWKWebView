//
//  H5EnterModel.h
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/3.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface H5EnterModel : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *detailTitle;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSDictionary *cookie;
@property(nonatomic, assign) NSInteger type;

@end
