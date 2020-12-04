//
//  WMCacheManager.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/19.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadCacheManager.h"

@import SSZipArchive;

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

NSString *const WM_defaultCachePathName =@"AppCache";

@interface WMDownloadCacheManager(){
    dispatch_semaphore_t _lock;
}
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
        NSString *memoryNameSpace = [@"memory.WMCacheManager" stringByAppendingString:WM_defaultCachePathName];
        
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.name = memoryNameSpace;
        _lock = dispatch_semaphore_create(1);
        
        _operationQueue = dispatch_queue_create("dispatch.WMCacheManager", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark -- public method

/// 删除文件数据
/// @param filePath 文件路径
/// @param isSuccess 移除结果回调
- (void)removeItemAtPath:(NSString *)filePath isSuccess:(void(^)(BOOL isSuccess))isSuccess {
    if (filePath.exists) {
        Lock();
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if (isSuccess) {
            isSuccess(result);
        }
        Unlock();
    }
}
/// 清除所有下载缓存数据
- (void)removeAllItems {
    if (WMDownload_resource_history_cache_PATH.exists){
        Lock();
        [[NSFileManager defaultManager] removeItemAtPath:WMDownload_resource_history_cache_PATH error:nil];
        Unlock();
    }
}

/// 下载数据存储文件路径
/// @param dictPath 外部传入文件路径
/// @param url  下载数据的地址
- (NSString *)createTempFilePathWithDictPath:(NSString *)dictPath url:(NSString *)url pathExtension:(nonnull NSString *)pathExtension{
    NSAssert(![url checkStringIsEmpty], @"下载地址不能为空");
    
    /// 文件存储路径不存在，使用默认路径
    if ([dictPath checkStringIsEmpty]) {
        dictPath = WMDownload_resource_history_cache_PATH;
    }
    
    /// 数据已经下载完成不再创建临时文件
    if ([self getFilePathWithDirecPath:dictPath url:url].exists){
        return @"";
    }
    
    /// 临时文件创建
    NSString *tempFilename = [NSString stringWithFormat:@"%@.%@", [url MD5],pathExtension];
    NSString *tempFilePath = [dictPath stringByAppendingPathComponent:tempFilename];
    /// 创建文件
    if (![tempFilePath exists]){ /// 文件路径不存在才创建文件
        Lock();
        [tempFilePath createFile];
        Unlock();
    }
    return tempFilePath;
}


/// 获取下载完成地址
/// @param direcPath 临时数据地址
/// @param url 下载数据地址
- (NSString *)getFilePathWithDirecPath:(NSString *)direcPath url:(NSString *)url {
    NSAssert(![direcPath checkStringIsEmpty], @"文件路径不能为空");
    NSAssert(![url checkStringIsEmpty], @"下载地址不能为空");
    
    NSString *namePath = [NSString stringWithFormat:@"%@.%@", [url MD5],url.pathExtension];
    NSString *filePath = [direcPath stringByAppendingPathComponent:namePath];
    return filePath;
}

/// 解压zip文件
/// @param filePath 文件本地存储路径
- (void)unzipDownloadFile:(NSString *)filePath unzipHandle:(void(^)(NSString *unZipPath))handle{
    if (![filePath.extension isEqualToString:@"zip"]){
        return;
    }
    /// 只有zip文件才解压
    if (filePath.exists){ /// 文件存在
        NSString *toPath = [filePath.prefix stringByAppendingPathComponent:[filePath.name MD5]];
        [SSZipArchive unzipFileAtPath:filePath toDestination:toPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            if (error) { /// 解压失败删除本地解压数据
                NSLog(@"解压失败  ---- filePath === %@",filePath);
                [[WMDownloadCacheManager sharedInstance] removeItemAtPath:toPath isSuccess:^(BOOL isSuccess) {
                    if (isSuccess == false){
                        NSLog(@"删除文件失败  ----- %@",filePath);
                    }
                }];
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
            tempFilePath:(NSString *)tempFilePath
        progressInfoData:(NSData *)progressInfoData
        progressInfoPath:(NSString *)progressInfoPath
               isSuccess:(void(^)(BOOL success))isSuccess {
    if (!receiveData || !tempFilePath || !progressInfoData || !progressInfoPath) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(NO);
            });
        }
        return;
    }
    /// 同时保存resumeData 和 进度数据
    __weak typeof(self) weakSelf = self;
    [self writeReceiveData:receiveData filePath:tempFilePath isSuccess:^(BOOL success) {
        if (success) {
            [weakSelf writeReceiveData:progressInfoData filePath:progressInfoPath isSuccess:^(BOOL success) {
                if (success) {
                    if (isSuccess) {
                        isSuccess(YES);
                    }
                } else { /// 下一个没有保存成功，删除上一个已经保存的本地数据
                    [weakSelf removeCacheDataWithPath:tempFilePath];
                }
            }];
        }
    }];
}

- (void)writeReceiveData:(NSData *)receiveData
                filePath:(NSString *)filePath
               isSuccess:(void(^)(BOOL success))isSuccess {
    if (!receiveData || !filePath) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                isSuccess(NO);
            });
        }
        return;
    }
    [self.memoryCache setObject:receiveData forKey:filePath];
    
    dispatch_async(self.operationQueue,^{
        BOOL result = [self setContent:receiveData writeToFile:filePath];
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    isSuccess(result);
                }
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
- (NSData *)getCacheDataWithPath:(NSString *)path {
    if (!path) return  nil;
    NSData *obj = [self.memoryCache objectForKey:path];
    if (obj) {
        return obj;
    }else{
        NSData *diskdata= [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        if (diskdata) {
            [self.memoryCache setObject:diskdata forKey:path];
        }
       return diskdata;
    }
}
/// 删除缓存数据
/// @param path 地址
/// @param key url
- (void)removeCacheDataWithTempFilePath:(NSString *)tempFilePath progressInfoPath:(NSString *)progressInfoPath {
    [self removeCacheDataWithPath:tempFilePath];
    [self removeCacheDataWithPath:progressInfoPath];
}

/// 删除断点下载数据
/// @param path 地址
- (void)removeCacheDataWithPath:(NSString *)path {
    if (!path) return;
    /// 先输出内存缓存
    [self.memoryCache removeObjectForKey:path];
    /// 再删除磁盘缓存
    [self removeItemAtPath:path isSuccess:^(BOOL isSuccess) {
    }];
}

@end
