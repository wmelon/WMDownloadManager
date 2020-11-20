//
//  WMDownloadAdapter.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMDownloadResponseStatus) {
    WMDownloadResponseStatusDefault = 0,        //初始状态
    WMDownloadResponseStatusSuccess,            //成功
    WMDownloadResponseStatusProgress,           //正在请求中
    WMDownloadResponseStatusFailure,            //失败
    WMDownloadResponseStatusCancel,             //任务被取消
    WMDownloadResponseStatusNoSpace,            //手机空间不足
};

@interface WMDownloadAdapter : NSObject

/// 请求返回状态
@property (nonatomic, assign, readonly) WMDownloadResponseStatus respStatus;

/// 请求完成之后的提示信息
@property (nonatomic, copy  , readonly) NSString * msg;

/// 请求成功返回数据
//@property (nonatomic, strong, readonly) id responseObject;

/// 请求成功返回字典结构数据
//@property (nonatomic, strong, readonly) NSDictionary *responseDictionary;

/// 请求成功返回二进制数据
//@property (nonatomic, strong, readonly) NSData *responseData;

/// 请求返回业务状态码
//@property (nonatomic, assign, readonly) NSInteger statusCode;

/// http的状态码
//@property (nonatomic, assign, readonly) NSInteger httpCode;

/// 请求失败
@property (nonatomic, strong, readonly) NSError * error;

/// 请求进度
@property (nonatomic, strong, readonly) NSProgress *progress;

/// 本地存储数据文件路径
@property (nonatomic, copy  , readonly) NSString *storeFilePath;

/// 文件名称
@property (nonatomic, copy  , readonly) NSString *storeFileName;

/// 当前下载百分比
@property (nonatomic, assign, readonly) double currentProgres;

#pragma mark -- 构建请求体需要的方法

/// 初始化请求对象
+ (instancetype)downloadWithUrl:(NSString *)downloadUrl;

/// 请求参数  这个适用于确定字典不为空的情况
- (void)downloadParameters:(NSDictionary *)params;

/// 请求参数
- (void)downloadParameterSetValue:(id)value forKey:(NSString *)key;

/// 文件下载存储路径和文件路径
- (void)configFilePath:(NSString *)filePath;

#pragma mark -- downloadmanager 需要使用的方法

/// 获取请求的网络地址
- (NSString *)getReallyDownloadUrl;

/// 请求进度处理
/// @param progress 进度数据
- (void)responseAdapterWithProgress:(NSProgress *)progress;

/// 下载完成处理
/// @param response 返回数据
/// @param task 请求task
/// @param filePath 存储下载数据文件路径
/// @param error 下载失败
- (void)responseAdapterWithResult:(NSURLResponse *)response
                         filePath:(NSURL *)filePath
                            error:(NSError *)error;

/**获取请求参数*/
- (NSDictionary *)getRequestParameter;

/// 请求公共参数
- (NSDictionary *)getRequestPublicParameter;

@end

NS_ASSUME_NONNULL_END
