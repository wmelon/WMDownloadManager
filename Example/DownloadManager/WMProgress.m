//
//  WMProgress.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/28.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMProgress.h"

@interface WMProgress()
@end

@implementation WMProgress

/// 构造函数
/// @param totalUnitCount 总数据量
/// @param completedUnitCount 已下载数据量
/// @param fractionCompleted 完成百分比
+ (instancetype)progressWithTotalUnitCount:(int64_t)totalUnitCount
                        completedUnitCount:(int64_t)completedUnitCount
                         fractionCompleted:(double)fractionCompleted {
    return [[self alloc] initWithProgressWithTotalUnitCount:totalUnitCount completedUnitCount:completedUnitCount fractionCompleted:fractionCompleted];
}

/// 构造函数
/// @param totalUnitCount 总数据量
/// @param completedUnitCount 已下载数据量
/// @param fractionCompleted 完成百分比
- (instancetype)initWithProgressWithTotalUnitCount:(int64_t)totalUnitCount
                        completedUnitCount:(int64_t)completedUnitCount
                         fractionCompleted:(double)fractionCompleted {
    if (self = [super init]) {
        _totalUnitCount = totalUnitCount;
        _completedUnitCount = completedUnitCount;
        _fractionCompleted = fractionCompleted;
    }
    return self;
}
@end
