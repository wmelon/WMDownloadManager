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
/// @param url 下载地址
+ (NSString *)filenameWithDownloadUrl:(NSString *)url;

/// 文件是否存在
/// @param filePath 文件路径
+ (BOOL)fileExistsAtPath:(NSString *)filePath;

/// 删除文件数据
/// @param filePath 文件路径
+ (void)removeItemAtPath:(NSString *)filePath;

/// 下载数据存储地址
/// @param filePath 外部传入文件路径
+ (NSString *)storeDictPath:(NSString *)filePath;

/// 清除所有下载缓存数据
+ (void)cleanDisk;

/// 清除制定文件
/// @param filePath 文件路径
+ (void)cleanDiskWithFilePath:(NSString *)filePath;

/// 加压zip文件
/// @param filePath 文件本地存储路径
+ (void)unzipDownloadFile:(NSString *)filePath unzipHandle:(void(^)(NSString *unZipPath))handle;
@end

NS_ASSUME_NONNULL_END
