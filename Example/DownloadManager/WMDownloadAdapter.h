//
//  WMDownloadAdapter.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "WMProgress.h"
#import "WMDownloadCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMDownloadResponseStatus) {
    WMDownloadResponseStatusDefault = 0,         //初始状态
    WMDownloadResponseStatusDownloading,         //下载中
    WMDownloadResponseStatusFailure ,            //失败
    WMDownloadResponseStatusSuccess ,            //成功
};

@interface WMDownloadAdapter : NSObject

/// 下载状态
@property (nonatomic, assign, readonly) WMDownloadResponseStatus downloadStatus;

/// 请求完成之后的提示信息
@property (nonatomic, copy  , readonly) NSString * msg;

/// 请求失败
@property (nonatomic, strong, readonly) NSError * error;

/// 请求进度
@property (nonatomic, strong, readonly) WMProgress *progress;

/// 本地缓存文件夹路径
@property (nonatomic, copy  , readonly) NSString *direcPath;

/// 临时存储数据路径
@property (nonatomic, copy  , readonly) NSString *downloadTempPath;

/// 本地存储数据文件路径
@property (nonatomic, copy  , readonly) NSString *filePath;

/// zip文件解压后的地址 （只有zip文件格式的数据才会有这个解压地址）
@property (nonatomic, copy  , readonly) NSString *unZipFilePath;

/// 网络请求参数
@property (nonatomic, strong, readonly) NSMutableDictionary * parameterDict;

/// 下载资源地址 /// 外部传入的请求地址  可能不包含域名，所以真实的请求地址需要进行二次拼接
@property (nonatomic, copy  , readonly) NSString *downloadUrl;

/// 网络请求队列
@property (nonatomic, strong, readonly) NSURLSessionTask *sessionTask;

#pragma mark -- 构建请求体需要的方法

/// 初始化请求对象
+ (instancetype)downloadWithUrl:(NSString *)downloadUrl direcPath:(NSString *)direcPath;

/// 请求参数  这个适用于确定字典不为空的情况
- (void)downloadParameters:(NSDictionary *)params;

/// 请求参数
- (void)downloadParameterSetValue:(id)value forKey:(NSString *)key;

#pragma mark -- downloadmanager 需要使用的方法
    
/// 配置session
- (void)configSessionManager:(AFHTTPSessionManager *)sessionManager;

/// 获取请求的网络地址
/// @param url 请求地址
/// @param sessionManager 请求管理器
- (NSString *)getReallyDownloadUrl:(NSString *)url;

/// 请求进度处理
/// @param progress 进度数据
- (void)responseAdapterWithProgress:(NSProgress *)progress;

/// 下载完成处理
/// @param response 返回数据
/// @param error 下载失败
- (void)responseAdapterWithResult:(NSURLResponse *)response
                            error:(NSError *)error;

/**获取请求参数*/
- (NSDictionary *)getRequestParameter;

/// 获取上次缓存的数据
- (NSData *)getResumeData;

/// 请求公共参数
- (NSDictionary *)getRequestPublicParameter;

/// 设置请求队列
/// @param sessionTask 当前请求队列
- (void)requestSessionTask:(NSURLSessionTask *)sessionTask;

/// 暂停或者取消下载都
- (void)downloadStop;

@end

NS_ASSUME_NONNULL_END
