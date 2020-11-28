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

/// 根据下载地址获取文件名
/// @param url 下载地址  地址经过MD5加密作为文件名
+ (NSString *)filenameWithDownloadUrl:(NSString *)url;

/// 向目录文件下写入data数据
/// @param receiveData 下载的data数据
/// @param dictPath 文件目录
+ (void)writeReceiveData:(NSData *)receiveData dictPath:(NSString *)dictPath;

/// 当前下载长度
/// @param filePath文件路径
+ (NSInteger)currentLengthWithFilePath:(NSString *)filePath;

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


/// 将文件拷贝路径
/// @param path from
/// @param toPath to
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath;

/// 解压zip文件
/// @param filePath 文件本地存储路径
+ (void)unzipDownloadFile:(NSString *)filePath unzipHandle:(void(^)(NSString *unZipPath))handle;

@end

NS_ASSUME_NONNULL_END
