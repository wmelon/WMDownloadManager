//
//  WMDownloadCacheManager+WMFilePath.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadCacheManager+WMFilePath.h"

static NSString *const kTeacherVideo = @"teacherVedio";
static NSString *const kTeacherFront = @"teacherFront";
static NSString *const kWebMobile    = @"web-mobile";
static NSString *const kPreview      = @"preview";
static NSString *const kSVGA         = @"svga";
static NSString *const kHomework     = @"homework";
static NSString *const kEvent        = @"event";
static NSString *const kQuestion     = @"question";
static NSString *const kPicture      = @"picture";
static NSString *const kAiPlayer     = @"aiPlayer";

@implementation WMDownloadCacheManager (WMFilePath)

/// 检查字符串是否为空
/// @param string 字符串
+ (BOOL)checkStringIsEmpty:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]] || string == (id)kCFNull || [string isEqualToString:@""]) {
        return true;
    }
    return false;
}

/// 预习课存储地址
/// @param lessonId 课程id
/// @param resourceId 源数据id
/// @param version 版本号
/// @param url 下载地址
+ (NSString *)previewPathWith:(NSString *)lessonId resourceId:(NSString *)resourceId version:(NSString *)version url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kPreview];
    NSString *dirLesson = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", lessonId]];
    NSString *dirID = [dirLesson stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", resourceId]];
    NSString *dirVersion = [dirID stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", version]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirVersion stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// 家庭作业存储地址
/// @param homeworkId 家庭作业id
/// @param url 下载数据地址
+ (NSString *)homeworkPath:(NSString *)homeworkId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kHomework];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", homeworkId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// svga数据存储地址
/// @param svgaId
/// @param url 下载地址
+ (NSString *)svgaPath:(NSString *)svgaId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kSVGA];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", svgaId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// event存储地址
/// @param eventId 事件id
/// @param url 下载地址
+ (NSString *)eventPath:(NSString *)eventId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kEvent];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", eventId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// 问题存储路径
/// @param questionId 问题id
/// @param url 下载地址
+ (NSString *)questionPath:(NSString *)questionId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kQuestion];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", questionId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// 绘画本存储路径
/// @param pictureId 绘画本id
/// @param url 下载地址
+ (NSString *)picturePath:(NSString *)pictureId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kPicture];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", pictureId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// 老师视频存储路径
/// @param teacherVedioId 老师id
/// @param url 视频地址
+ (NSString *)teacherVedioPath:(NSString *)teacherVedioId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kTeacherVideo];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", teacherVedioId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// 老师提前预习数据存储路径
/// @param teacherFrontId 老师id
/// @param url 下载地址
+ (NSString *)teacherFrontPath:(NSString *)teacherFrontId url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kTeacherFront];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", teacherFrontId]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// 存储地址
/// @param webMobile 手机号
/// @param url 下载地址
+ (NSString *)webMobilePath:(NSString *)webMobile url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kWebMobile];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", webMobile]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

/// ai视频存储路径
/// @param aiPlayer
/// @param url
+ (NSString *)aiPlayerPath:(NSString *)aiPlayer url:(NSString *)url {
    if ([self checkStringIsEmpty:url]) return @"";
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kAiPlayer];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", aiPlayer]];
    NSString *filename = [self filenameWithDownloadUrl:url];
    NSString *pFile = [dirPreview stringByAppendingPathComponent:filename];
    
    return pFile;
}

@end
