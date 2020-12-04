//
//  WMDownloadAdapter.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadAdapter.h"

/// 已经接收
#define CountOfBytesReceived        @"countOfBytesReceived"
/// 一共数据量
#define CountOfBytesExpectedToReceive    @"countOfBytesExpectedToReceive"

@interface WMDownloadAdapter()
/// 断点下载进度本地存储路径
@property (nonatomic, copy  ) NSString *resumeProgressInfoFile;
@end

@implementation WMDownloadAdapter

@synthesize parameterDict = _parameterDict, downloadTempPath = _downloadTempPath ,filePath = _filePath ,direcPath = _direcPath,progress = _progress;

/// 初始化请求对象
+ (instancetype)downloadWithUrl:(NSString *)downloadUrl direcPath:(nonnull NSString *)direcPath{
    return [[self alloc] initWithUrl:downloadUrl direcPath:direcPath];
}

- (instancetype)initWithUrl:(NSString *)downloadUrl direcPath:(NSString *)direcPath {
    if (self = [super init]) {
        _downloadUrl = downloadUrl;
    
        /// 可以为空，空的话就保底默认地址
        _direcPath = direcPath;
        
        /// 临时存储数据地址
        NSString *downloadUrl = [self getReallyDownloadUrl:self.downloadUrl];
        _downloadTempPath = [[WMDownloadCacheManager sharedInstance] createTempFilePathWithDictPath:direcPath url:downloadUrl pathExtension:@"tmp"];
        _resumeProgressInfoFile = [[WMDownloadCacheManager sharedInstance] createTempFilePathWithDictPath:direcPath url:downloadUrl pathExtension:@"proTmp"];
        
        /// 监听进入后台
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:self queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf downloadStop];
        }];
    }
    return self;
}
/// 暂停下载存储当前下载数据
- (void)downloadStop {
    NSURLSessionTask *task = self.sessionTask;
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]]){
        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)task;
        [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            
            /// 本地缓存处理
            if (resumeData.length > 0) {
                /// 处理下载进度数据
                NSMutableDictionary *resumeDataInfo = [NSMutableDictionary new];
                resumeDataInfo[CountOfBytesReceived] = @(self.sessionTask.countOfBytesReceived);
                resumeDataInfo[CountOfBytesExpectedToReceive] = @(self.sessionTask.countOfBytesExpectedToReceive);
                NSData *resumeProgressInfoData = [NSJSONSerialization dataWithJSONObject:resumeDataInfo options:0 error:nil];
                
                /// 缓存数据和进度数据同时写入内存缓存和本地缓存
                [[WMDownloadCacheManager sharedInstance] writeReceiveData:resumeData tempFilePath:self.downloadTempPath progressInfoData:resumeProgressInfoData progressInfoPath:self.resumeProgressInfoFile isSuccess:^(BOOL isSuccess) {
                    if (isSuccess) {
                        NSLog(@"--------------------\n暂停下载请求，保存当前已下载文件进度\n\n-downloadTempPath-:%@\n\n-downloadFileDirectory-:%@\n-----------------",self.downloadTempPath ,self.resumeProgressInfoFile);
                    } else {
                        NSLog(@"保存数据失败  ----- %@   %@",self.downloadTempPath,self.resumeProgressInfoFile );
                    }
                }];
            }
        }];
    }
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

- (NSString *)filePath{
    if (_filePath) {
        return _filePath;
    }
    _filePath = [[WMDownloadCacheManager sharedInstance] getFilePathWithDirecPath:self.direcPath url:[self getReallyDownloadUrl:self.downloadUrl]];
    return _filePath;
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
/// 获取上次缓存的数据
- (NSData *)getResumeData {
    /// 下载本地存储路径
    NSString *tempFilePath = self.downloadTempPath;

    /// 缓存数据
    NSData *resumeData = [[WMDownloadCacheManager sharedInstance] getCacheDataWithPath:tempFilePath];
    
    return resumeData;
}
- (WMProgress *)progress {
    if (_progress) {
        return _progress;
    }
    
    NSData *jsonData = [[WMDownloadCacheManager sharedInstance] getCacheDataWithPath:self.resumeProgressInfoFile];
    NSDictionary *proJson = [self progressInfoWithData:jsonData];
    if ([proJson isKindOfClass:[NSDictionary class]]) {
        /// 总数据
        int64_t totalUnitCount = [proJson[CountOfBytesExpectedToReceive] integerValue];
        /// 下载完成数据
        int64_t completedUnitCount = [proJson[CountOfBytesReceived] integerValue];
        /// 完成百分比
        double fractionCompleted = 100.0 * completedUnitCount / totalUnitCount;
        
        /// 本地进度数据
        WMProgress *progress = [WMProgress progressWithTotalUnitCount:totalUnitCount completedUnitCount:completedUnitCount fractionCompleted:fractionCompleted];
        _progress = progress;
    }
    return _progress;
}
- (NSDictionary *)progressInfoWithData:(NSData *)jsonData {
    if (jsonData.length > 0) {
        NSDictionary *resumeDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        return resumeDict;
    }
    return nil;
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
    [[WMDownloadCacheManager sharedInstance] removeCacheDataWithTempFilePath:TempFilePath progressInfoPath:self.resumeProgressInfoFile];
    
    /// 解压
    if (filePath.exists) {
        /// 解压缩包
        [[WMDownloadCacheManager sharedInstance] unzipDownloadFile:filePath unzipHandle:^(NSString * _Nonnull unZipPath) {
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
    /// 取消之前先存储下来数据
    [self downloadStop];
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
