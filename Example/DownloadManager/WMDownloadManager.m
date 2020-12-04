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
        
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json", @"text/plain",@"text/javascript",@"text/xml",@"image/*",@"multipart/form-data",@"application/octet-stream",@"application/zip",nil];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
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
    /// 请求地址
    NSString *downloadUrl = [downloadAdapter getReallyDownloadUrl:downloadAdapter.downloadUrl];
    
    if (downloadAdapter.downloadStatus == WMDownloadResponseStatusDownloading || downloadAdapter.filePath.exists){ /// 正在下载 或 需要下载的文件已经存在不再继续下载
        return;
    } else {  /// 开始下载
        [self downloadStartWithRequest:downloadAdapter complete:complete downloadUrl:downloadUrl];
    }
}

+ (void)downloadStartWithRequest:(WMDownloadAdapter *)downloadAdapter complete:(WMDownloadCompletionHandle)complete downloadUrl:(NSString *)downloadUrl {
    
    /// 请求参数
    NSDictionary *paramer = [downloadAdapter getRequestParameter];
    
    NSLog(@">>>> %@ > %@ -> parameters %@",downloadUrl, @"Download" ,paramer);
    
    NSURLSessionDownloadTask *downloadTask = [self downloadWithRequest:downloadAdapter downloadUrl:downloadUrl resumeData:[downloadAdapter getResumeData] savePath:[self AppDownloadPath:downloadAdapter] progress:^(NSProgress *downloadProgress) {
        /// 请求进度
        [downloadAdapter responseAdapterWithProgress:downloadProgress];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete){
                complete(downloadAdapter);
            }
        });
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        /// 下载完成删除下载对象
        [self removeRequestFromRecord:downloadAdapter];

        /// 下载失败缓存已经下载数据
        if (error){
            [self cancelDownload:downloadAdapter];
        }
        
        /// 下载完成处理
        [downloadAdapter responseAdapterWithResult:response error:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete){
                complete(downloadAdapter);
            }
        });
    }];
    
    /// 设置请求队列
    [downloadAdapter requestSessionTask:downloadTask];
    downloadTask.priority = 1000;
    [downloadTask resume];
    /// 添加进下载数据结构中
    [self addRequestToRecord:downloadAdapter];
}
+ (NSURLSessionDownloadTask *)downloadWithRequest:(WMDownloadAdapter *)downloadAdapter
                                      downloadUrl:(NSString *)downloadUrl
                                       resumeData:(NSData *)resumeData
                                         savePath:(NSString *)savePath
                                         progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    /// 下载session管理器
    AFHTTPSessionManager *sessionManager = [self sessionManager:downloadAdapter];
    
    /// 获取自定义session , 不显示采用默认的
    [downloadAdapter configSessionManager:sessionManager];
    
    if (resumeData.length > 0) {
        return [sessionManager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            downloadProgressBlock ? downloadProgressBlock(downloadProgress) : nil;
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            /// targetPath 是临时缓存数据的地址
            NSURL *URL = [NSURL fileURLWithPath:savePath];
            return URL;
        } completionHandler:completionHandler];
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
        return [sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            downloadProgressBlock ? downloadProgressBlock(downloadProgress) : nil;
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            /// targetPath 是临时缓存数据的地址
            NSURL *URL = [NSURL fileURLWithPath:savePath];
            return URL;
        } completionHandler:completionHandler];
    }
}

/// 批量下载
/// @param complete 所有完成请求回调  其中一个下载失败不会影响其它下载项
/// @param downloadAdapter 下载请求结构体
+ (void)batchDownloadWithComplete:(WMBatchDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter , ... NS_REQUIRES_NIL_TERMINATION {
    /// 获取所有的请求
    id eachObject;
    va_list argumentList;
    NSMutableArray<WMDownloadAdapter *> *requestArray;
    if (downloadAdapter){
        requestArray = [NSMutableArray arrayWithObjects:downloadAdapter, nil];
        va_start(argumentList, downloadAdapter);
        while ((eachObject = va_arg(argumentList, id))) {
            [requestArray addObject:eachObject];
        }
        va_end(argumentList);
    }
    [self addBatchRequests:requestArray completeHandler:complete];
}
+ (void)addBatchRequests:(NSArray<WMDownloadAdapter *> *)requestArray
                    completeHandler:(WMBatchDownloadCompletionHandle)completeHandler {

    dispatch_group_t group = dispatch_group_create();
    for (WMDownloadAdapter *request in requestArray) {
        /// 有多少个请求完成标识就得有多少个请求等待
        /// 批量异步下载  同步更新不需要只要请求进度
        dispatch_group_enter(group);
        ///
        [self downloadWithcomplete:^(WMDownloadAdapter * _Nonnull response) {
            /// 单个网络完成
            if (response.downloadStatus == WMDownloadResponseStatusFailure || response.downloadStatus == WMDownloadResponseStatusSuccess) {
                dispatch_group_leave(group);
            }
        } downloadAdapter:request];
    }
    /// 所有请求完成之后的回调 请求对象就是返回对象
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        if (completeHandler){
            completeHandler(requestArray);
        }
    });
}
/// 下载文件真实存储路径
+ (NSString *)AppDownloadPath:(WMDownloadAdapter *)downloadAdapter {
    /// 断点接受数据地址
    NSString *savePath = downloadAdapter.filePath;
    return savePath;
}

#pragma mark - 获取网络状态
+ (BOOL)isNetworkReachable{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable;
}

+ (BOOL)isNetworkWiFi{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

+ (AFNetworkReachabilityStatus)networkReachability{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

#pragma mark -- 下载状态变更相关方法

/// 取消所有网络请求
+ (void)cancelAllDownload {
    [self downloadOperate:(WMDownloadResponseStatusDefault)];
}
///// 暂停所有下载请求
//+ (void)pauseAllDownload {
//    [self downloadOperate:(WMDownloadResponseStatusPause)];
//}
///// 断点续传所有下载
//+ (void)resumeAllDownload {
//    [self downloadOperate:(WMDownloadResponseStatusProgress)];
//}

/// 取消单个下载请求
+ (void)cancelDownload:(WMDownloadAdapter *)download {
    /// 必须在取消之前，不然无法获取到 resumeData
    [download downloadStop];
    [self removeRequestFromRecord:download];
}

/// 暂停单个下载请求
/// @param download 下载对象
//+ (void)pauseDownload:(WMDownloadAdapter *)download {
//    [download pauseDownload];
//    [self downloadStopWithRequest:download];
//}

/// 断点续传单个请求
/// @param download 下载对象
//+ (void)resumeDownload:(WMDownloadAdapter *)download {
//    [download resumeDownload];
//}

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
                case WMDownloadResponseStatusDefault:
                    [self cancelDownload:request];
                    break;
//                case WMDownloadResponseStatusPause:
//                    [self pauseDownload:request];
//                    break;
//                case WMDownloadResponseStatusProgress:
//                    [self resumeDownload:request];
//                    break;
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
