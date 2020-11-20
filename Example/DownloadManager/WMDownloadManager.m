//
//  WMDownloadManager.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/19.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadManager.h"
#import "AFHTTPSessionManager.h"
#import "WMDownloadCacheManager.h"

@implementation WMDownloadManager

/**
 所有的HTTP请求共享一个AFHTTPSessionManager

 @return AFHTTPSessionManager
 */
+ (AFHTTPSessionManager *)downloaderSessionManager {
    static AFHTTPSessionManager *downloaderSessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSURLSessionConfiguration *configer = [NSURLSessionConfiguration defaultSessionConfiguration];
        configer.timeoutIntervalForRequest = 20.0f;
        downloaderSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configer];
        downloaderSessionManager.requestSerializer = [self requestSerializer];
        downloaderSessionManager.responseSerializer = [self responseSerializer];
        // AFSSLPinningModeNone 使用证书不验证模式
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        [downloaderSessionManager setSecurityPolicy:securityPolicy];
    });
    return downloaderSessionManager;
}
+ (AFHTTPRequestSerializer *)requestSerializer{
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    return requestSerializer;
}
+ (AFHTTPResponseSerializer *)responseSerializer{
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer
                                                    serializerWithReadingOptions:NSJSONReadingAllowFragments];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
    return responseSerializer;
}
/// 单个下载请求
/// @param complete 下载完成回调
/// @param downloadAdapter 下载数据结构体
+ (void)downloadWithcomplete:(WMDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter {
    /// 请求地址
    NSString *downloadUrl = [downloadAdapter getReallyDownloadUrl];
    /// 请求参数
    NSDictionary *paramer = [downloadAdapter getRequestParameter];
    NSLog(@">>>> %@ > %@ -> parameters %@",downloadUrl, @"Download" ,paramer);
    /// 构建afnetworking 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    NSURLSessionDownloadTask *downloadTask = [self.downloaderSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 请求进度
            [downloadAdapter responseAdapterWithProgress:downloadProgress];
            if (complete){
                complete(downloadAdapter);
            }
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /// 下载本地存储路径
        NSString *filePath = [WMDownloadCacheManager fileCachePath:downloadAdapter.storeFilePath downloadUrl:downloadUrl];
        return [NSURL URLWithString:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 下载完成处理
            [downloadAdapter responseAdapterWithResult:response filePath:filePath error:error];
            if (complete){
                complete(downloadAdapter);
            }
        });
    }];
    downloadTask.priority = 1000;
    [downloadTask resume];
}

/// 批量下载
/// @param complete 所有完成请求回调  其中一个下载失败不会影响其它下载项
/// @param downloadAdapter 下载请求结构体
+ (void)batchDownloadWithComplete:(WMDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter , ... NS_REQUIRES_NIL_TERMINATION {
    
}

/// 取消单个下载请求
+ (void)cancelDownload:(WMDownloadAdapter *)download {
    
}

/// 取消所有网络请求
+ (void)cancelAllDownload {
    
}
/// 是否已经取消请求
+ (BOOL)isCancelled:(WMDownloadAdapter *)download {
    return YES;
}

/// 是否正在请求
+ (BOOL)isExecuting:(WMDownloadAdapter *)download {
    return YES;
}

@end
