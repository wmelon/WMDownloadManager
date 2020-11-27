//
//  WMCacheManager.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/19.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadCacheManager.h"
#import <CommonCrypto/CommonDigest.h>

@import SSZipArchive;

@implementation WMDownloadCacheManager

/// 检查字符串是否为空
/// @param string 字符串
+ (BOOL)checkStringIsEmpty:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]] || string == (id)kCFNull || [string isEqualToString:@""]) {
        return true;
    }
    return false;
}
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
/// 文件真实存储全路径
/// @param dictPath 除去文件名称之外的文件夹路径
/// @param url 下载资源地址
+ (NSString *)filePathWithDictPath:(NSString *)dictPath url:(NSString *)url {
    NSString *filePath  = [dictPath stringByAppendingPathComponent:[self filenameWithDownloadUrl:url]];
    return filePath;
}

/// 检查文件是否存储
/// @param filePath 文件路径
+ (BOOL)fileExistsAtPath:(NSString *)filePath {
    return filePath.exists;
}

/// 删除本地存在的文件
/// @param filePath 文件路径
+ (void)removeItemAtPath:(NSString *)filePath {
    if ([self checkStringIsEmpty:filePath]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:filePath] error:nil];
}

/// 下载数据存储文件路径
/// @param dictPath 外部传入文件路径 , 可能为空，为空直接使用默认地址
+ (NSString *)dictPathWithDictPath:(NSString *)dictPath {
    /// 文件存储路径不存在，使用默认路径
    if ([self checkStringIsEmpty:dictPath]) {
        dictPath = WMDownload_resource_history_cache_PATH;
    }
    /// 如果有文件名称后缀需要剔除掉
    NSString *extension = dictPath.extension;
    if (![self checkStringIsEmpty:extension]){
        dictPath = [dictPath prefix];
    }
    /// 创建文件
    [dictPath createFile];
    return dictPath;
}
/// 清除下载缓存数据
+ (void)cleanDisk {
    if (WMDownload_resource_history_cache_PATH.exists){
        [[NSFileManager defaultManager] removeItemAtPath:WMDownload_resource_history_cache_PATH error:nil];
    }
}
/// 清除制定文件
/// @param filePath 文件路径
+ (void)cleanDiskWithFilePath:(NSString *)filePath {
    if (filePath.exists) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
/// 解压zip文件
/// @param filePath 文件本地存储路径
+ (void)unzipDownloadFile:(NSString *)filePath unzipHandle:(void(^)(NSString *unZipPath))handle{
    if (![filePath.extension isEqualToString:@"zip"]){
        return;
    }
    /// 只有zip文件才解压
    if (filePath.exists){ /// 文件存在
        NSString *toPath = [filePath.prefix stringByAppendingPathComponent:[self MD5:filePath.name]];
        __weak typeof(self) weakself = self;
        [SSZipArchive unzipFileAtPath:filePath toDestination:toPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            if (error) { /// 解压失败删除本地解压数据
                NSLog(@"解压失败  ---- filePath === %@",filePath);
                [weakself cleanDiskWithFilePath:toPath];
            } else {  /// 解压成功
                if (handle){
                    handle(toPath);
                }
            }
        }];
    } else {
        NSLog(@"需要解压的文件不存在  ---- filePath === %@",filePath);
    }
}
@end
