//
//  WMCacheManager.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/19.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Path.h"

NS_ASSUME_NONNULL_BEGIN

#define WMDownload_resource_history_cache_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"com.AiKit.download.files"] // 缓存默认路径

@interface WMDownloadCacheManager : NSObject

/// 初始化单例对象
+ (WMDownloadCacheManager *)sharedInstance;

/// 删除文件数据
/// @param filePath 文件路径
/// @param isSuccess 移除结果回调
- (void)removeItemAtPath:(NSString *)filePath isSuccess:(void(^)(BOOL isSuccess))isSuccess;

/// 清除所有下载缓存数据
- (void)removeAllItems;

/// 下载数据存储文件路径
/// @param dictPath 外部传入文件路径 , 可能为空，为空直接使用默认地址
/// @param url  下载数据的地址
- (NSString *)createTempFilePathWithDictPath:(NSString *)dictPath url:(NSString *)url;


/// 获取下载完成地址
/// @param direcPath 下载数据路径
- (NSString *)getFilePathWithDirecPath:(NSString *)direcPath url:(NSString *)url;

/// 解压zip文件
/// @param filePath 文件本地存储路径
- (void)unzipDownloadFile:(NSString *)filePath unzipHandle:(void(^)(NSString *unZipPath))handle;


/// 向目录文件下写入data数据
/// @param receiveData 下载的data数据
/// @param dictPath 文件目录
- (void)writeReceiveData:(NSData *)receiveData dictPath:(NSString *)dictPath key:(NSString *)key isSuccess:(void(^)(BOOL isSuccess))isSuccess;

/// 获取缓存数据
/// @param path 文件路径
/// @param key 一般是下载url地址
- (NSData *)getCacheDataWithPath:(NSString *)path key:(NSString *)key;


/// 删除断点下载数据
/// @param path 地址
/// @param key url
- (void)removeCacheDataWithPath:(NSString *)path key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
