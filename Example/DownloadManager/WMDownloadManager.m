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
+ (AFHTTPSessionManager *)sessionManager:(WMDownloadAdapter *)requestAdapter {
    static AFHTTPSessionManager *sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sessionManager = [AFHTTPSessionManager manager];
        sessionManager.operationQueue.maxConcurrentOperationCount = 5;
        
        // AFSSLPinningModeNone 使用证书不验证模式
        sessionManager.securityPolicy.allowInvalidCertificates = NO;
        sessionManager.securityPolicy.validatesDomainName = YES;
    });
    
    /// 请求头中设置公共参数
    if ([requestAdapter respondsToSelector:@selector(getRequestPublicParameter)]) {
        NSDictionary *dict = [requestAdapter getRequestPublicParameter];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    return sessionManager;
}
/// 单个下载请求
/// @param complete 下载完成回调
/// @param downloadAdapter 下载数据结构体
+ (void)downloadWithcomplete:(WMDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter {
    /// 下载session管理器
    AFHTTPSessionManager *sessionManager = [self sessionManager:downloadAdapter];
    
    /// 请求地址
    NSString *downloadUrl = [downloadAdapter getReallyDownloadUrl:downloadAdapter.downloadUrl sessionManager:sessionManager];
    /// 请求参数
    NSDictionary *paramer = [downloadAdapter getRequestParameter];
    NSLog(@">>>> %@ > %@ -> parameters %@",downloadUrl, @"Download" ,paramer);
    
    /// 创建本地存储数据文件夹地址
    NSString *dictPath = [WMDownloadCacheManager dictPathWithDictPath:downloadAdapter.direcPath];
    /// 下载本地存储路径
    NSString *filePath = [WMDownloadCacheManager filePathWithDictPath:dictPath url:downloadUrl];
    
    /// 构建afnetworking 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 请求进度
            [downloadAdapter responseAdapterWithProgress:downloadProgress];
            if (complete){
                complete(downloadAdapter);
            }
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *URL = [NSURL fileURLWithPath:filePath];
        return URL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePathUrl, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 下载完成处理
            [downloadAdapter responseAdapterWithResult:response filePath:filePath error:error];
            if (complete){
                complete(downloadAdapter);
            }
        });
    }];
    /// 设置请求队列
    [downloadAdapter requestSessionTask:downloadTask];
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
    NSParameterAssert(download != nil);
    NSURLSessionTask *task = download.sessionTask;
//    [self removeRequestFromRecord:request];
    [task cancel];
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
