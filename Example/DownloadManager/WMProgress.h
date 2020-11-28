//
//  WMProgress.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/28.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMProgress : NSObject
/// 总数据
@property (nonatomic, assign, readonly) int64_t totalUnitCount;
/// 下载完成数据
@property (nonatomic, assign, readonly) int64_t completedUnitCount;
/// 完成百分比
@property (nonatomic, assign, readonly) double fractionCompleted;


/// 构造函数
/// @param totalUnitCount 总数据量
/// @param completedUnitCount 已下载数据量
/// @param fractionCompleted 完成百分比
+ (instancetype)progressWithTotalUnitCount:(int64_t)totalUnitCount
                        completedUnitCount:(int64_t)completedUnitCount
                         fractionCompleted:(double)fractionCompleted;

@end

NS_ASSUME_NONNULL_END
