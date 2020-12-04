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

#define WMDownload_resource_history_cache_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"com.AiKit.download.files"]// 缓存默认路径

@interface WMDownloadCacheManager : NSObject

+ (WMDownloadCacheManager *)sharedInstance;

/// MD5加密字符串
+ (NSString *)MD5:(NSString *)string;

/// 删除文件数据
/// @param filePath 文件路径
+ (void)removeItemAtPath:(NSString *)filePath;

/// 清除所有下载缓存数据
+ (void)removeAllItems;

/// 下载数据存储文件路径
/// @param dictPath 外部传入文件路径 , 可能为空，为空直接使用默认地址
/// @param url  下载数据的地址
+ (NSString *)createTempFilePathWithDictPath:(NSString *)dictPath url:(NSString *)url;


/// 获取下载完成地址
/// @param tempFilePath 临时数据地址
+ (NSString *)getFilePathWithTempFilePath:(NSString *)tempFilePath url:(NSString *)url;

/// 解压zip文件
/// @param filePath 文件本地存储路径
+ (void)unzipDownloadFile:(NSString *)filePath unzipHandle:(void(^)(NSString *unZipPath))handle;


/// 向目录文件下写入data数据
/// @param receiveData 下载的data数据
/// @param dictPath 文件目录
- (void)writeReceiveData:(NSData *)receiveData dictPath:(NSString *)dictPath key:(NSString *)key isSuccess:(void(^)(BOOL isSuccess))isSuccess;

/// 获取缓存数据
/// @param path 文件路径
/// @param key 一般是下载url地址
- (NSData *)getCacheDataWithPath:(NSString *)path key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
