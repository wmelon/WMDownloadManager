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
+ (AFHTTPSessionManager *)getManager {
    static AFHTTPSessionManager *downloaderSessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        downloaderSessionManager = [AFHTTPSessionManager manager];
        downloaderSessionManager.operationQueue.maxConcurrentOperationCount = 5;
        
//        NSURLSessionConfiguration *configer = [NSURLSessionConfiguration defaultSessionConfiguration];
//        configer.timeoutIntervalForRequest = 20.0f;
//        downloaderSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configer];
//        downloaderSessionManager.requestSerializer = [self requestSerializer];
//        downloaderSessionManager.responseSerializer = [self responseSerializer];
        // AFSSLPinningModeNone 使用证书不验证模式
        downloaderSessionManager.securityPolicy.allowInvalidCertificates = NO;
        downloaderSessionManager.securityPolicy.validatesDomainName = YES;
    });
    return downloaderSessionManager;
}
//+ (AFHTTPRequestSerializer *)requestSerializer{
//    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
//    return requestSerializer;
//}
//+ (AFHTTPResponseSerializer *)responseSerializer{
//    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer
//                                                    serializerWithReadingOptions:NSJSONReadingAllowFragments];
//    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
//    return responseSerializer;
//}
//+ (NSString *)replaceTaskHostWithUrl:(NSString *)baseUrl{
//    if ([ZMYDomainManager instance].httpdnsEnable && ([ZMYDomainManager instance].isIpv6 == NO) && [ZMDL share].switchForDownLoad) {
//        self.session.securityPolicy.allowInvalidCertificates = YES;
//        self.session.securityPolicy.validatesDomainName = NO;
//
//        NSString *host = [[NSURL URLWithString:baseUrl] host];
//        NSLog(@"baseUrl===========================%@",baseUrl);
//        NSString *ip = [[ZMYDomainManager instance] getHostIP:host];
//        NSString *replaceBaseUrl = @"";
//        if (ip && ip.length >0) {
//            replaceBaseUrl =  [baseUrl stringByReplacingOccurrencesOfString:host withString:ip];
//        }else{
//            return baseUrl;
//        }
//        NSLog(@"replaceBaseUrl===========================%@",replaceBaseUrl);
//        [ZMAIKitAnalyseManager analyse:KT_Event_HttpDnsReplaceIp attributes:@{
//            @"userId":Safe_Param([ZMAIKitManager manager].params.userInfo.userId),
//            @"requestPath":Safe_Param(replaceBaseUrl)
//        }];
//        return replaceBaseUrl;
//
//    }else{
//        [self downloaderSessionManager].securityPolicy.allowInvalidCertificates = NO;
//        [self downloaderSessionManager].securityPolicy.validatesDomainName = YES;
//        return baseUrl;

//    }
//    return baseUrl;
//}
/// 单个下载请求
/// @param complete 下载完成回调
/// @param downloadAdapter 下载数据结构体
+ (void)downloadWithcomplete:(WMDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter {
    /// 请求地址
    NSString *downloadUrl = [downloadAdapter getReallyDownloadUrl];
    /// 请求参数
    NSDictionary *paramer = [downloadAdapter getRequestParameter];
    NSLog(@">>>> %@ > %@ -> parameters %@",downloadUrl, @"Download" ,paramer);
    
    /// 创建本地存储数据地址
    NSString *storeDictPath = [WMDownloadCacheManager storeDictPath:downloadAdapter.storeFilePath];
    /// 下载本地存储路径
    NSString *storeFilePath = downloadAdapter.storeFilePath;
    
    /// 下载session管理器
    AFHTTPSessionManager *sessionManager = [WMDownloadManager getManager];
    
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
        
        NSURL *URL = [NSURL fileURLWithPath:storeFilePath];
        return URL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /// 下载完成处理
            [downloadAdapter responseAdapterWithResult:response filePath:storeFilePath error:error];
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
