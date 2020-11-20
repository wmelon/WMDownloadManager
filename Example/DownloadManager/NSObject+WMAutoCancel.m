//
//  NSObject+WMAutoCancel.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "NSObject+WMAutoCancel.h"
#import <objc/runtime.h>
#import "WMDownloadManager.h"

@interface WMDeallocRequests : NSObject
@property (strong, nonatomic) NSMutableArray<WMDownloadAdapter *> *downloadArray;
@property (strong, nonatomic) NSLock *lock;
@end

@implementation WMDeallocRequests
- (instancetype)init{
    if (self = [super init]) {
        _downloadArray = [NSMutableArray array];
        _lock = [[NSLock alloc]init];
    }
    return self;
}
- (void)addRequest:(WMDownloadAdapter *)download{
    if (!download || ![download isKindOfClass:[WMDownloadAdapter class]]) {
        return;
    }
    [_lock lock];
    [self.downloadArray addObject:download];
    [_lock unlock];
}

- (void)dealloc{
    [self.downloadArray enumerateObjectsUsingBlock:^(WMDownloadAdapter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [WMDownloadManager cancelDownload:obj];
    }];
    [_lock lock];
    [self.downloadArray removeAllObjects];
    [_lock unlock];
}
@end


@implementation NSObject (WMAutoCancel)
/// 界面销毁停止下载
/// @param download 需要停止的下载对象
- (void)autoCancelOnDealloc:(WMDownloadAdapter *)download {
    [[self deallocRequests] addRequest:download];
}

- (WMDeallocRequests *)deallocRequests{
    WMDeallocRequests *requests = objc_getAssociatedObject(self, _cmd);
    if (!requests) {
        requests = [[WMDeallocRequests alloc] init];
        objc_setAssociatedObject(self, _cmd, requests, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return requests;
}
@end
