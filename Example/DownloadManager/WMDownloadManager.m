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

/// 存储所有下载对象
static NSMutableDictionary<NSNumber * ,WMDownloadAdapter *> *_requestRecord;

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
//        sessionManager.responseSerializer = [self responseSerializer];
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
+ (AFHTTPResponseSerializer *)responseSerializer{
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
                                                    
//                                                    serializerWithReadingOptions:NSJSONReadingAllowFragments];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"video/mpeg",@"video/mp4",nil];
    return responseSerializer;
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
    
    /// 下载本地存储路径
    NSString *TempFilePath = [WMDownloadCacheManager createTempFilePathWithDictPath:downloadAdapter.direcPath url:downloadUrl];
    
    /// 获取当前文件已经下载的大小
    NSInteger currentLength = [WMDownloadCacheManager currentLengthWithFilePath:TempFilePath];
    
    /// 断点接受数据地址
    NSString *filePath = [WMDownloadCacheManager getFilePathWithTempFilePath:TempFilePath url:downloadUrl];
    
    /// 构建afnetworking 请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    
    // 设置HTTP请求头中的Range
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *downloadTask = [sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 请求进度
            [downloadAdapter responseAdapterWithProgress:downloadProgress currentLength:currentLength];
            if (complete){
                complete(downloadAdapter);
            }
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        /// 下载完成删除下载对象
        [self removeRequestFromRecord:downloadAdapter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 下载完成处理
            [downloadAdapter responseAdapterWithResult:response filePath:filePath error:error];
            
            /// 下载完成拷贝
            BOOL success = [WMDownloadCacheManager moveItemAtPath:TempFilePath toPath:filePath];
            if (success == false) { /// 拷贝失败，先删掉文件再试一次
                [WMDownloadCacheManager removeItemAtPath:filePath];
                [WMDownloadCacheManager moveItemAtPath:TempFilePath toPath:filePath];
            }
            
            if (complete){
                complete(downloadAdapter);
            }
        });
    }];
    /// 接受data数据
    [sessionManager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        /// 存储数据
        [WMDownloadCacheManager writeReceiveData:data dictPath:TempFilePath];
    }];
    /// 设置请求队列
    [downloadAdapter requestSessionTask:downloadTask];
    downloadTask.priority = 1000;
    [downloadTask resume];
    /// 添加进下载数据结构中
    [self addRequestToRecord:downloadAdapter];
}

/// 批量下载
/// @param complete 所有完成请求回调  其中一个下载失败不会影响其它下载项
/// @param downloadAdapter 下载请求结构体
+ (void)batchDownloadWithComplete:(WMDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter , ... NS_REQUIRES_NIL_TERMINATION {
    
}
#pragma mark -- 下载状态变更相关方法

/// 取消单个下载请求
+ (void)cancelDownload:(WMDownloadAdapter *)download {
    [download cancelDownload];
    [self removeRequestFromRecord:download];
}

/// 取消所有网络请求
+ (void)cancelAllDownload {
    [self downloadOperate:(WMDownloadResponseStatusCancel)];
}
/// 暂停所有下载请求
+ (void)pauseAllDownload {
    [self downloadOperate:(WMDownloadResponseStatusPause)];
}
/// 断点续传所有下载
+ (void)resumeAllDownload {
    [self downloadOperate:(WMDownloadResponseStatusProgress)];
}

/// 暂停单个下载请求
/// @param download 下载对象
+ (void)pauseDownload:(WMDownloadAdapter *)download {
    [download pauseDownload];
}

/// 断点续传单个请求
/// @param download 下载对象
+ (void)resumeDownload:(WMDownloadAdapter *)download {
    [download resumeDownload];
}

/// 处理网络请求操作
+ (void)downloadOperate:(WMDownloadResponseStatus)status{
    NSArray *allKeys;
    @synchronized(self) {
        allKeys = [self.requestRecord allKeys];
    }
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            WMDownloadAdapter *request;
            @synchronized(self) {
                request = self.requestRecord[key];
            }
            switch (status) {
                case WMDownloadResponseStatusCancel:
                    [self cancelDownload:request];
                    break;
                case WMDownloadResponseStatusPause:
                    [self pauseDownload:request];
                    break;
                case WMDownloadResponseStatusProgress:
                    [self resumeDownload:request];
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark -- 下载对象管理方法
/// 请求开始时添加请求到队列中
+ (void)addRequestToRecord:(WMDownloadAdapter *)request{
    @synchronized(self) {  /// 保证临界区内的代码线程安全
        self.requestRecord[@(request.sessionTask.taskIdentifier)] = request;
    }
}
/// 请求完成后移除队列中请求
+ (void)removeRequestFromRecord:(WMDownloadAdapter *)request{
    @synchronized(self) {
        [self.requestRecord removeObjectForKey:@(request.sessionTask.taskIdentifier)];
    }
}

/// 存储请求对象
+ (NSMutableDictionary<NSNumber *,WMDownloadAdapter *> *)requestRecord{
    if (_requestRecord == nil){
        _requestRecord = [NSMutableDictionary dictionary];
    }
    return _requestRecord;
}

@end
