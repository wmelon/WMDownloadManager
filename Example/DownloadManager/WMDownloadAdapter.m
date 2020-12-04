//
//  WMDownloadAdapter.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadAdapter.h"
#import "WMDownloadCacheManager.h"

@interface WMDownloadAdapter()
@end

@implementation WMDownloadAdapter

@synthesize parameterDict = _parameterDict, downloadTempPath = _downloadTempPath ,filePath = _filePath ,direcPath = _direcPath;

/// 初始化请求对象
+ (instancetype)downloadWithUrl:(NSString *)downloadUrl direcPath:(nonnull NSString *)direcPath{
    return [[self alloc] initWithUrl:downloadUrl direcPath:direcPath];
}

- (instancetype)initWithUrl:(NSString *)downloadUrl direcPath:(NSString *)direcPath {
    if (self = [super init]) {
        _downloadUrl = downloadUrl;
        _direcPath = direcPath;
    }
    return self;
}

/// 请求参数  这个适用于确定字典不为空的情况
- (void)downloadParameters:(NSDictionary *)params {
    NSAssert(![params isKindOfClass:[NSDictionary class]], @"参数必须是字典类型");
    [self.parameterDict setValuesForKeysWithDictionary:params];
}

/// 请求参数拼接
- (void)downloadParameterSetValue:(id)value forKey:(NSString *)key {
    [self.parameterDict setValue:value forKey:key];
}

- (NSString *)downloadTempPath {
    return [WMDownloadCacheManager createTempFilePathWithDictPath:self.direcPath url:[self getReallyDownloadUrl:self.downloadUrl]];
}

- (NSString *)filePath{
    return [WMDownloadCacheManager getFilePathWithTempFilePath:self.downloadTempPath url:[self getReallyDownloadUrl:self.downloadUrl]];
}

#pragma mark -- downloadmanager 需要使用的方法

/// 配置session
- (void)configSessionManager:(AFHTTPSessionManager *)sessionManager {
    NSLog(@"%@  --- 子类可以重写   %@",self,sessionManager);
}
/// 设置请求队列
/// @param sessionTask 当前请求队列
- (void)requestSessionTask:(NSURLSessionTask *)sessionTask {
    _sessionTask = sessionTask;
}

/// 获取请求的网络地址
/// @param url 请求地址
- (NSString *)getReallyDownloadUrl:(NSString *)url {
    return url;
}

/**获取请求参数*/
- (NSDictionary *)getRequestParameter {
    return self.parameterDict;
}

/// 请求公共参数  需要公共参数子类重写这个方法
- (NSDictionary *)getRequestPublicParameter {
    return @{};
}

/// 请求进度处理
/// @param progress 进度数据
- (void)responseAdapterWithProgress:(NSProgress *)progress {
    /// 总数据
    int64_t totalUnitCount = progress.totalUnitCount;
    /// 下载完成数据
    int64_t completedUnitCount = progress.completedUnitCount;
    /// 完成百分比
    double fractionCompleted = 100.0 * completedUnitCount / totalUnitCount;
    WMProgress *wmPro = [WMProgress progressWithTotalUnitCount:totalUnitCount
                                            completedUnitCount:completedUnitCount
                                             fractionCompleted:fractionCompleted];
    _progress = wmPro;
    _downloadStatus = WMDownloadResponseStatusDownloading;
}

/// 下载完成处理
/// @param response 返回数据
/// @param filePath 存储下载数据文件路径
/// @param error 下载失败
- (void)responseAdapterWithResult:(NSURLResponse *)response
                            error:(NSError *)error {
    if (error) { /// 下载失败处理
        [self downloadFail:_filePath error:error response:response];
    } else {  /// 下载成功处理
        [self downloadSuccess:_filePath TempFilePath:_downloadTempPath response:response];
    }
}
- (void)downloadFail:(NSString *)filePath error:(NSError *)error response:(NSURLResponse *)response{
    _error = error;
    NSLog(@"😂😂😂 %@ 请求失败 (地址 ===> %@) ===> statusCode: %zd",self ,response.URL.absoluteString,error.code);
    
    if (error.code == -999){ /// 取消下载
        _msg = @"取消下载";
    } else {
        _msg = @"下载失败";
    }
    _downloadStatus = WMDownloadResponseStatusFailure;
}
- (void)downloadSuccess:(NSString *)filePath TempFilePath:(NSString *)TempFilePath response:(NSURLResponse *)response{
    /// 下载完成移除临时文件
    [WMDownloadCacheManager removeItemAtPath:TempFilePath];
    
    /// 解压
    if (filePath.exists) {
        /// 解压缩包
        [WMDownloadCacheManager unzipDownloadFile:filePath unzipHandle:^(NSString * _Nonnull unZipPath) {
            _unZipFilePath = unZipPath;
        }];
    }
    
    NSLog(@"😄😄😄 %@ 请求成功  (地址 ===> %@)",self ,response.URL.absoluteString);
    if (filePath){
        _msg = @"下载成功";
        _downloadStatus = WMDownloadResponseStatusSuccess;
    } else {
        _msg = @"缓存失败";
        _downloadStatus = WMDownloadResponseStatusFailure;
    }
}
/// 取消单个下载请求
- (void)cancelDownload {
    [self.sessionTask cancel];
}

#pragma mark -- getter
- (NSMutableDictionary *)parameterDict{
    if (_parameterDict == nil){
        _parameterDict = [NSMutableDictionary dictionary];
    }
    return _parameterDict;
}

@end
