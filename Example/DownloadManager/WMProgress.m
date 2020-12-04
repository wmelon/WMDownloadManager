//
//  WMProgress.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/28.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMProgress.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

NSString *const ZFDownloadNetworkSpeedNotificationKey = @"WMDownloadNetworkSpeedNotificationKey";
NSString *const ZFUploadNetworkSpeedNotificationKey   = @"WMUploadNetworkSpeedNotificationKey";
NSString *const ZFNetworkSpeedNotificationKey         = @"WMNetworkSpeedNotificationKey";


typedef void(^WMNetWorkSpeedHandle)(NSString *downloadNetworkSpeed);

@interface WMNetworkSpeedMonitor : NSObject{
    // 总网速
    uint32_t _iBytes;
    uint32_t _oBytes;
    uint32_t _allFlow;
    
    // wifi网速
    uint32_t _wifiIBytes;
    uint32_t _wifiOBytes;
    uint32_t _wifiFlow;
    
    // 3G网速
    uint32_t _wwanIBytes;
    uint32_t _wwanOBytes;
    uint32_t _wwanFlow;
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy  ) WMNetWorkSpeedHandle speedHandle;
@end

@implementation WMNetworkSpeedMonitor

//@synthesize downloadNetworkSpeed = _downloadNetworkSpeed;

- (instancetype)init {
    if (self = [super init]) {
        _iBytes = _oBytes = _allFlow = _wifiIBytes = _wifiOBytes = _wifiFlow = _wwanIBytes = _wwanOBytes = _wwanFlow = 0;
    }
    return self;
}

// 开始监听网速
- (void)startNetworkSpeedMonitor:(WMNetWorkSpeedHandle)speedHandle {
    _speedHandle = speedHandle;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkNetworkSpeed) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];
    }
}

// 停止监听网速
- (void)stopNetworkSpeedMonitor {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (NSString *)stringWithbytes:(int)bytes {
    if (bytes < 1024) { // B
        return [NSString stringWithFormat:@"%dB", bytes];
    } else if (bytes >= 1024 && bytes < 1024 * 1024) { // KB
        return [NSString stringWithFormat:@"%.0fKB", (double)bytes / 1024];
    } else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) { // MB
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    } else { // GB
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

- (void)checkNetworkSpeed {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) return;
    
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    uint32_t allFlow = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family) continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) continue;
        if (ifa->ifa_data == 0) continue;
        
        // network
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
        
        //wifi
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow = wifiIBytes + wifiOBytes;
        }
        
        //3G or gprs
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow = wwanIBytes + wwanOBytes;
        }
    }
    
    freeifaddrs(ifa_list);
    if (_iBytes != 0) {
        NSString *downloadNetworkSpeed = [[self stringWithbytes:iBytes - _iBytes] stringByAppendingString:@"/s"];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZFDownloadNetworkSpeedNotificationKey object:nil userInfo:@{ZFNetworkSpeedNotificationKey:downloadNetworkSpeed}];

        if (self.speedHandle) {
            self.speedHandle(downloadNetworkSpeed);
        }
    }
    
    _iBytes = iBytes;
    
//    if (_oBytes != 0) {
//        _uploadNetworkSpeed = [[self stringWithbytes:oBytes - _oBytes] stringByAppendingString:@"/s"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:ZFUploadNetworkSpeedNotificationKey object:nil userInfo:@{ZFNetworkSpeedNotificationKey:_uploadNetworkSpeed}];
//        ZFPlayerLog(@"uploadNetworkSpeed :%@",_uploadNetworkSpeed);
//    }
    
    _oBytes = oBytes;
}

@end


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
        
        /// 监控下载速度
//        [[[WMNetworkSpeedMonitor alloc] init] startNetworkSpeedMonitor:^(NSString *downloadNetworkSpeed) {
//            _downloadNetworkSpeed = downloadNetworkSpeed;
//        }];
    }
    return self;
}

@end
