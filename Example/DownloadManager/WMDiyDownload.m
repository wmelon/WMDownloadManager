//
//  WMDiyDownload.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/27.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDiyDownload.h"

@implementation WMDiyDownload

- (NSDictionary *)getRequestPublicParameter {
    return [self publicParamConfig];
}
/// 获取请求的网络地址
- (NSString *)getReallyDownloadUrl:(NSString *)url {
    /// 有些请求是不需要拼接公共参数的，比如下载.mp4等资源的时候
    return url;
//    NSString *paramsUrl = [self publicParamsAppending:url];
//    return paramsUrl;
}
- (NSDictionary *)publicParamConfig {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"2.0.0" forKey:@"ver"];
    return dict;
}
- (NSString *)publicParamsAppending:(NSString *)url {
    // 初始化参数变量
    __block NSString *str = @"?";
    /// 为请求地址添加公共参数
    NSDictionary *dict = [self publicParamConfig];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"="];
        str = [str stringByAppendingString:obj];
        str = [str stringByAppendingString:@"&"];
    }];
    // 处理多余的&以及返回含参url
    if (str.length > 1) {
        // 去掉末尾的&
        str = [str substringToIndex:str.length - 1];
    }
    // 返回含参url
    return [url stringByAppendingString:str];
}
@end
