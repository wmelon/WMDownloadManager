//
//  WMDiyDownload.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/27.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDiyDownload.h"

@implementation WMDiyDownload

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
//+ (NSString *)replaceTaskHostWithUrl:(NSString *)baseUrl{
//    if ([ZMYDomainManager instance].httpdnsEnable && ([ZMYDomainManager instance].isIpv6 == NO) && [ZMDL share].switchForDownLoad) {
//        self.session.securityPolicy.allowInvalidCertificates = YES;
//        self.session.securityPolicy.validatesDomainName = NO;
//
//        NSString *host = [[NSURL URLWithString:baseUrl] host];
//        NSLog(@"baseUrl===========================%@",baseUrl);
//        NSString *ip = [[ZMYDomainManager instance] getHostIP:host];
//        NSString *replaceBaseUrl = @"";
//        if (ip && ip.length >0) {
//            replaceBaseUrl =  [baseUrl stringByReplacingOccurrencesOfString:host withString:ip];
//        }else{
//            return baseUrl;
//        }
//        NSLog(@"replaceBaseUrl===========================%@",replaceBaseUrl);
//        [ZMAIKitAnalyseManager analyse:KT_Event_HttpDnsReplaceIp attributes:@{
//            @"userId":Safe_Param([ZMAIKitManager manager].params.userInfo.userId),
//            @"requestPath":Safe_Param(replaceBaseUrl)
//        }];
//        return replaceBaseUrl;
//
//    }else{
//        [self downloaderSessionManager].securityPolicy.allowInvalidCertificates = NO;
//        [self downloaderSessionManager].securityPolicy.validatesDomainName = YES;
//        return baseUrl;

//    }
//    return baseUrl;
//}
#pragma mark -- 重写的方法
- (NSDictionary *)getRequestPublicParameter {
    return [self publicParamConfig];
}

/// 获取请求的网络地址
/// @param url 请求地址
/// @param sessionManager 请求管理器
- (NSString *)getReallyDownloadUrl:(NSString *)url sessionManager:(AFHTTPSessionManager *)sessionManager {
    /// 有些请求是不需要拼接公共参数的，比如下载.mp4等资源的时候
    /// 这里处理地址的 ip 直连  ，DNS解析等一系列操作
//    if (needDns) {
//        sessionManager.securityPolicy.allowInvalidCertificates = NO;
//        sessionManager.securityPolicy.validatesDomainName = YES;
//    } else {
//        sessionManager.securityPolicy.allowInvalidCertificates = YES;
//        sessionManager.securityPolicy.validatesDomainName = NO;
//    }
    
    return url;
//    NSString *paramsUrl = [self publicParamsAppending:url];
//    return paramsUrl;
}

@end
