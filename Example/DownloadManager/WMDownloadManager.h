//
//  WMDownloadManager.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/19.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMDownloadAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/// 下载完成回调
typedef void(^WMDownloadCompletionHandle)(WMDownloadAdapter *response);

/// 批量下载完成回调
typedef void(^WMBatchDownloadCompletionHandle)(NSArray<WMDownloadAdapter *> *responses);

@interface WMDownloadManager : NSObject

/// 单个下载请求
/// @param complete 下载完成回调
/// @param downloadAdapter 下载数据结构体
+ (void)downloadWithcomplete:(WMDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter;

#warning ---- 批量下载还有问题，后续看怎么优化
/// 批量下载
/// @param complete 所有完成请求回调  其中一个下载失败不会影响其它下载项
/// @param downloadAdapter 下载请求结构体
//+ (void)batchDownloadWithComplete:(WMBatchDownloadCompletionHandle)complete downloadAdapter:(WMDownloadAdapter *)downloadAdapter , ... NS_REQUIRES_NIL_TERMINATION;

/// 取消单个下载请求
+ (void)cancelDownload:(WMDownloadAdapter *)download;

/// 取消所有网络请求
+ (void)cancelAllDownload;

/// 暂停单个下载请求
/// @param download 下载对象
+ (void)pauseDownload:(WMDownloadAdapter *)download;

/// 暂停所有下载请求
+ (void)pauseAllDownload;

/// 断点续传单个请求
/// @param download 下载对象
+ (void)resumeDownload:(WMDownloadAdapter *)download;

/// 断点徐闯所有下载
+ (void)resumeAllDownload;

@end

NS_ASSUME_NONNULL_END
