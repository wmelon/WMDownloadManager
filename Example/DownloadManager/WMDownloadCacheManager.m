//
//  WMCacheManager.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/19.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadCacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Path.h"

@implementation WMDownloadCacheManager

/// 字符串MD5加密
/// @param string 需要加密的字符串
+ (NSString *)MD5:(NSString *)string {
    const char* str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return [ret lowercaseString];
}

/// 根据下载地址获取文件名
/// @param url 下载地址
+ (NSString *)filenameWithDownloadUrl:(NSString *)url {
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [self MD5:url], url.pathExtension];
    return filename;
}
/// 检查文件是否存储
/// @param filePath 文件路径
+ (BOOL)fileExistsAtPath:(NSString *)filePath {
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return result;
}

/// 删除本地存在的文件
/// @param filePath 文件路径
+ (void)removeItemAtPath:(NSString *)filePath {
    if ([self checkStringIsEmpty:filePath]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:filePath] error:nil];
}

/// 下载数据存储地址
/// @param filePath 外部传入文件路径
/// @param downloadUrl 下载的数据地址
+ (NSString *)fileCachePath:(NSString *)filePath downloadUrl:(NSString *)downloadUrl{
    /// 下载路径不存在直接返回
    if ([self checkStringIsEmpty:downloadUrl]){
        return @"";
    }
    /// 文件存储路径不存在，使用默认路径
    if ([self checkStringIsEmpty:filePath]) {
        filePath = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:downloadUrl.pathExtension];
    }
    /// 创建文件
    [filePath createFile];
    return filePath;
}

/// 检查字符串是否为空
/// @param string 字符串
+ (BOOL)checkStringIsEmpty:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]] || string == (id)kCFNull || [string isEqualToString:@""]) {
        return true;
    }
    return false;
}
/// 清除下载缓存数据
+ (void)cleanDisk {
    [[NSFileManager defaultManager] removeItemAtPath:WMDownload_resource_history_cache_PATH error:nil];
}
/// 清除制定文件
/// @param filePath 文件路径
+ (void)cleanDiskWithFilePath:(NSString *)filePath {
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
