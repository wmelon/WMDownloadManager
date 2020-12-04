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

NSString *const zb_defaultCachePathName =@"AppCache";

@interface WMDownloadCacheManager()
/// 内存缓存
@property (nonatomic, strong) NSCache *memoryCache;
/// 文件操作队列
@property (nonatomic ,strong) dispatch_queue_t operationQueue;
@end

@implementation WMDownloadCacheManager

+ (WMDownloadCacheManager *)sharedInstance {
    static WMDownloadCacheManager *once;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        once = [[WMDownloadCacheManager alloc] init];
    });
    return once;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *memoryNameSpace = [@"memory.ZBCacheManager" stringByAppendingString:zb_defaultCachePathName];
        
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.name = memoryNameSpace;
        
        _operationQueue = dispatch_queue_create("dispatch.ZBCacheManager", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

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

/// 临时文件路径
/// @param url 下载地址
+ (NSString *)tempFilenameWithDownloadUrl:(NSString *)url {
    NSString *tempFilename = [NSString stringWithFormat:@"%@.tmp", [self MD5:url]];
    return tempFilename;
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

/// 向目录文件下写入data数据
/// @param receiveData 下载的data数据
/// @param dictPath 文件目录
- (void)writeReceiveData:(NSData *)receiveData
                dictPath:(NSString *)dictPath
                     key:(NSString *)key
               isSuccess:(void(^)(BOOL isSuccess))isSuccess{
    if (!receiveData || !key) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(NO);
            });
        }
        return;
    }
    [self.memoryCache setObject:receiveData forKey:key];
    
    dispatch_async(self.operationQueue,^{
        BOOL result = [self setContent:receiveData writeToFile:dictPath];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(result);
            });
        }
    });
}
- (BOOL)setContent:(NSObject *)content writeToFile:(NSString *)path{
    if (!content||!path){
        return NO;
    }
    if ([content isKindOfClass:[NSData class]]) {
        return  [(NSData *)content writeToFile:path atomically:YES];
    }else {
        NSLog(@"文件类型:%@,沙盒存储失败。",NSStringFromClass([content class]));
        return NO;
    }
    return NO;
}

/// 缓存数据
/// @param path 文件路径
/// @param key 一般是下载url地址
- (NSData *)getCacheDataWithPath:(NSString *)path key:(NSString *)key{
    if (!key) return nil;
    NSData *obj = [self.memoryCache objectForKey:key];
    if (obj) {
        return obj;
    }else{
        NSData *diskdata= [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        if (diskdata) {
            [self.memoryCache setObject:diskdata forKey:key];
        }
       return diskdata;
    }
}

@end
