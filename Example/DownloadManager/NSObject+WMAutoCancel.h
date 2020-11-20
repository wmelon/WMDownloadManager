//
//  NSObject+WMAutoCancel.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMDownloadAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (WMAutoCancel)

/// 界面销毁停止下载
/// @param download 需要停止的下载对象
- (void)autoCancelOnDealloc:(WMDownloadAdapter *)download;

@end

NS_ASSUME_NONNULL_END
