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
/// 外部传入的请求地址  可能不包含域名，所以真实的请求地址需要进行二次拼接
@property (nonatomic, copy  ) NSString *downloadUrl;
@end

@implementation WMDownloadAdapter

/// 初始化请求对象
+ (instancetype)downloadWithUrl:(NSString *)downloadUrl {
    return [[WMDownloadAdapter alloc] initWithUrl:downloadUrl];
}

- (instancetype)initWithUrl:(NSString *)downloadUrl {
    if (self = [super init]) {
        _downloadUrl = downloadUrl;
    }
    return self;
}

/// 请求参数  这个适用于确定字典不为空的情况
- (void)downloadParameters:(NSDictionary *)params {
    
}

/// 请求参数拼接
- (void)downloadParameterSetValue:(id)value forKey:(NSString *)key {
    
}
/// 文件下载存储路径和文件名称
- (void)configFilePath:(NSString *)filePath {
    _storeFilePath = filePath;
}

#pragma mark -- downloadmanager 需要使用的方法
/// 获取请求的网络地址
- (NSString *)getReallyDownloadUrl {
    return self.downloadUrl;
}
/**获取请求参数*/
- (NSDictionary *)getRequestParameter {
    return @{};
}

/// 请求公共参数
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
                         filePath:(NSURL *)filePath
                            error:(NSError *)error {
    if ([filePath isKindOfClass:[NSURL class]]){
        _storeFilePath = filePath.absoluteString;
    }
    
    if (error) { /// 下载失败处理
        [self downloadFail:_storeFilePath error:error response:response];
    } else {  /// 下载成功处理
        [self downloadSuccess:_storeFilePath response:response];
    }
}
- (void)downloadFail:(NSString *)filePath error:(NSError *)error response:(NSURLResponse *)response{
    _error = error;
    NSLog(@"😂😂😂 %@ 请求失败 %@ ===> statusCode: %zd",self ,response.URL.absoluteString,error.code);
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
    NSLog(@"😄😄😄 %@ 请求成功 %@ ===> filePath %@",self ,response.URL.absoluteString,filePath);
    if (filePath){ /// 存储失败
        _msg = @"缓存失败";
        _respStatus = WMDownloadResponseStatusSuccess;
    } else {
        _msg = @"下载成功";
        _respStatus = WMDownloadResponseStatusNoSpace;
    }
}
#pragma mark -- getter method
- (NSString *)storeFileName {
    return self.downloadUrl.pathExtension;
}
@end
