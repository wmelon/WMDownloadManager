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
@synthesize parameterDict = _parameterDict;

/// 初始化请求对象
+ (instancetype)downloadWithUrl:(NSString *)downloadUrl {
    return [[self alloc] initWithUrl:downloadUrl];
}

- (instancetype)initWithUrl:(NSString *)downloadUrl {
    if (self = [super init]) {
        _downloadUrl = downloadUrl;
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
/// 设置文件下载存储文件夹路径
- (void)configDirecPath:(NSString *)direcPath {
    _direcPath = direcPath;
}

#pragma mark -- downloadmanager 需要使用的方法
/// 获取请求的网络地址
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
    _progress = progress;
    _currentProgres = ((double)progress.completedUnitCount) / progress.totalUnitCount;
    _respStatus = WMDownloadResponseStatusProgress;
}
/// 下载完成处理
/// @param response 返回数据
/// @param filePath 存储下载数据文件路径
/// @param error 下载失败
- (void)responseAdapterWithResult:(NSURLResponse *)response
                         filePath:(NSString *)filePath
                            error:(NSError *)error {
    if ([filePath isKindOfClass:[NSString class]]){
        _filePath = filePath;
    } else if ([filePath isKindOfClass:[NSURL class]]){
        NSURL *url = (NSURL *)filePath;
        _filePath = url.absoluteString;
    }
    
    if (error) { /// 下载失败处理
        [self downloadFail:_filePath error:error response:response];
    } else {  /// 下载成功处理
        [self downloadSuccess:_filePath response:response];
    }
}
- (void)downloadFail:(NSString *)filePath error:(NSError *)error response:(NSURLResponse *)response{
    _error = error;
    NSLog(@"😂😂😂 %@ 请求失败 (地址 ===> %@) ===> statusCode: %zd",self ,response.URL.absoluteString,error.code);
    /// 下载失败删除本地数据
    if ([WMDownloadCacheManager fileExistsAtPath:filePath]){
        [WMDownloadCacheManager removeItemAtPath:filePath];
    }
    
    if (error.code == -999){ /// 取消下载
        _msg = @"取消下载";
        _respStatus = WMDownloadResponseStatusCancel;
    } else {
        _msg = @"下载失败";
        _respStatus = WMDownloadResponseStatusFailure;
    }
}
- (void)downloadSuccess:(NSString *)filePath response:(NSURLResponse *)response{
    NSLog(@"😄😄😄 %@ 请求成功  (地址 ===> %@)",self ,response.URL.absoluteString);
    if (filePath){
        _msg = @"下载成功";
        _respStatus = WMDownloadResponseStatusSuccess;
        /// 解压缩包
        [WMDownloadCacheManager unzipDownloadFile:filePath unzipHandle:^(NSString * _Nonnull unZipPath) {
            _unZipFilePath = unZipPath;
        }];
    } else {
        _msg = @"缓存失败";
        _respStatus = WMDownloadResponseStatusNoSpace;
    }
}
#pragma mark -- getter
- (NSMutableDictionary *)parameterDict{
    if (_parameterDict == nil){
        _parameterDict = [NSMutableDictionary dictionary];
    }
    return _parameterDict;
}
@end
