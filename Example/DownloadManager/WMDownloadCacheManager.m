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

#pragma mark -- private method
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
#pragma mark -- public method

/// 当前下载长度
/// @param filePath文件路径
+ (NSInteger)currentLengthWithFilePath:(NSString *)filePath {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([filePath exists]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:filePath error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

/// 临时文件路径
/// @param url 下载地址
+ (NSString *)tempFilenameWithDownloadUrl:(NSString *)url {
    NSString *tempFilename = [NSString stringWithFormat:@"%@.temp", [self MD5:url]];
    return tempFilename;
}

/// 向目录文件下写入data数据
/// @param receiveData 下载的data数据
/// @param dictPath 文件目录
+ (void)writeReceiveData:(NSData *)receiveData dictPath:(NSString *)dictPath {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:dictPath];
    
    // 指定数据的写入位置 -- 文件内容的最后面
    [fileHandle seekToEndOfFile];
    
    // 向沙盒写入数据
    [fileHandle writeData:receiveData];
}

/// 删除本地存在的文件
/// @param filePath 文件路径
+ (void)removeItemAtPath:(NSString *)filePath {
    if (filePath.exists) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
/// 清除所有下载缓存数据
+ (void)removeAllItems {
    if (WMDownload_resource_history_cache_PATH.exists){
        [[NSFileManager defaultManager] removeItemAtPath:WMDownload_resource_history_cache_PATH error:nil];
    }
}

/// 下载数据存储文件路径
/// @param filePath 外部传入文件路径 , 可能为空，为空直接使用默认地址
/// @param url  下载数据的地址
+ (NSString *)createTempFilePathWithDictPath:(NSString *)dictPath url:(NSString *)url {
    /// 文件存储路径不存在，使用默认路径
    if ([self checkStringIsEmpty:dictPath]) {
        dictPath = WMDownload_resource_history_cache_PATH;
    }
    /// 文件地址
    NSString *filePath  = [dictPath stringByAppendingPathComponent:[self tempFilenameWithDownloadUrl:url]];
    /// 创建文件
    if (![filePath exists]){ /// 文件路径不存在才创建文件
        [filePath createFile];
    }
    return filePath;
}
/// 获取下载完成地址
/// @param tempFilePath 临时数据地址
+ (NSString *)getFilePathWithTempFilePath:(NSString *)tempFilePath url:(NSString *)url {
    NSString *filePath = [NSString stringWithFormat:@"%@.%@",tempFilePath.namePath,url.pathExtension];
    return filePath;
}

/// 将文件拷贝路径
/// @param path from
/// @param toPath to
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:nil];
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
                [weakself removeItemAtPath:toPath];
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
