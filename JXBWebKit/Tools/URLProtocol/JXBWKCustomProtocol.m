//
//  MSWKCustomProtocol.m
//  JXBWebKit
//
//  Created by jinxiubo on 2018/5/9.
//  Copyright © 2018年 jinxiubo. All rights reserved.
//

#import "JXBWKCustomProtocol.h"
#import "JXBWKWebViewPool.h"
#import <UIKit/UIKit.h>

static NSString* const FilteredNewPostKey = @"FilteredNewPostKey";

@interface JXBWKCustomProtocol()
@property(nonatomic, strong) NSURLSessionDataTask *dataTask;
@end

@implementation JXBWKCustomProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if ([request.URL.scheme isEqualToString:@"post"]) {
        return YES;
    }
    
    if ([request.URL.absoluteString caseInsensitiveCompare:kWKWebViewReuseUrlString] == NSOrderedSame) {
        return YES;
    }
    
    //如果是已经拦截过的就放行
    if ([NSURLProtocol propertyForKey:FilteredNewPostKey inRequest:request]) {
        return NO;
    }
    
    return NO;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    if ([request.URL.scheme isEqualToString:@"post"]) {
        //获取oldScheme
        NSString *originScheme = request.allHTTPHeaderFields[@"oldScheme"];
        
        NSMutableString *urlString = [NSMutableString stringWithString:request.URL.absoluteString];
        
        NSRange schemeRange = [urlString rangeOfString:request.URL.scheme];
        
        [urlString replaceCharactersInRange:schemeRange withString:originScheme];
        
        //根据新的urlString生成新的request
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        //获取bodyParam
        NSString *bodyParam = request.allHTTPHeaderFields[@"bodyParam"];
        NSData *bodyData =[bodyParam dataUsingEncoding:NSUTF8StringEncoding];
        newRequest.HTTPMethod = @"POST";
        newRequest.HTTPBody = bodyData;
        
        //获取cookie
        NSString *cookie = request.allHTTPHeaderFields[@"Cookie"];
        [newRequest addValue:cookie forHTTPHeaderField:@"Cookie"];
        
        [NSURLProtocol setProperty:@YES forKey:FilteredNewPostKey inRequest:newRequest];
        
        return newRequest;
    }
    
    
    return request;
}

- (void)startLoading {
    NSURLRequest *request = [[self class] canonicalRequestForRequest:self.request];
    
    if ([request.URL.absoluteString caseInsensitiveCompare:kWKWebViewReuseUrlString] == NSOrderedSame) {
        NSData *responseData = [[self _getWebViewReuseLoadString] dataUsingEncoding:NSUTF8StringEncoding];
        [self.client URLProtocol:self didReceiveResponse:[[NSURLResponse alloc]initWithURL:self.request.URL MIMEType:@"text/html" expectedContentLength:responseData.length textEncodingName:@"UTF-8"] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:responseData];
        [self.client URLProtocolDidFinishLoading:self];
    }else{
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error) {
                [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
                
                [self.client URLProtocol:self didLoadData:data];
                
                [[self client] URLProtocolDidFinishLoading:self];
            }else{
                [self.client URLProtocol:self didFailWithError:error];
            }
        }];
        
        [task resume];
        
        self.dataTask = task;
    }
}

- (void)stopLoading {
    [self.dataTask cancel];
}

- (NSString *)_getWebViewReuseLoadString{
    return @"<html><head><meta name=\"viewport\" " @"content=\"initial-scale=1.0,width=device-width,user-scalable=no\"/><title>JXBWebKit-Reuse</title></head><body></body></html>";
}

@end
