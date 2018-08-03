//
//  WKWebView+CookiesManager.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/10.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "WKWebView+CookiesManager.h"


@implementation WKWebView (CookiesManager)

+ (NSString *)cookieStringWithParam:(NSDictionary *)params {
    __block NSMutableString *cookieStr = [NSMutableString string];
    
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(NSString* _Nonnull key, NSString* _Nonnull value, BOOL * _Nonnull stop) {
            [cookieStr appendString:[NSString stringWithFormat:@"%@=%@;", key, value]];
        }];
    }
    
    if (cookieStr.length > 1)[cookieStr deleteCharactersInRange:NSMakeRange(cookieStr.length - 1, 1)];
    
    return cookieStr.copy;
}

- (NSString *)jsCookieStringWithValidDomain:(NSString *)validDomain {
    NSString *cookieStr = [self cookieStringWithValidDomain:validDomain];
    
    NSString *jsCookieStr = [NSString stringWithFormat:@"document.cookie = '%@';",cookieStr];
    
    return jsCookieStr;
}

- (NSString *)cookieStringWithValidDomain:(NSString *)validDomain {
    @autoreleasepool {
        NSArray *cookieArr = [self sharedHTTPCookieStorage];
        
        NSMutableArray *marr = @[].mutableCopy;
        
        for (NSHTTPCookie *cookie in cookieArr) {
            if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
                continue;
            }
            
            if (![validDomain hasSuffix:cookie.domain] && ![cookie.domain hasSuffix:validDomain]) {
                continue;
            }
            
            NSString *value = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
            [marr addObject:value];
        }
        
        NSString *cookie = [marr componentsJoinedByString:@";"];
        
        return cookie;
    }
}

- (NSArray *)sharedHTTPCookieStorage {
    @autoreleasepool {
        NSMutableArray *cookieMarr = [NSMutableArray array];
        
        NSHTTPCookieStorage *sharedCookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        for (NSHTTPCookie *cookie in sharedCookies.cookies){
            [cookieMarr addObject:cookie];
        }
        
        //删除过期的cookie
        for (int i = 0; i < cookieMarr.count; i++) {
            NSHTTPCookie *cookie = [cookieMarr objectAtIndex:i];
            
            if (!cookie.expiresDate) {
                continue;
            }
            
            if ([cookie.expiresDate compare:self.currentTime]) {
                [cookieMarr removeObject:cookie];
                i--;
            }
        }
        
        return cookieMarr.copy;
    }
}

- (NSDate *)currentTime {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date  dateByAddingTimeInterval:interval];
    return localDate;
}

@end
