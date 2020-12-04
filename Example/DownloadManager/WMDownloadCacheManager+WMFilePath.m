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

+ (NSString *)previewPathWith:(NSString *)lessonId resourceId:(NSString *)resourceId version:(NSString *)version   {
     
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kPreview];
    NSString *dirLesson = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self MD5:lessonId]]];
    NSString *dirID = [dirLesson stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self MD5:resourceId]]];
    NSString *dirVersion = [dirID stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self MD5:version]]];
     
    return dirVersion;
}

/// 家庭作业存储地址
/// @param homeworkId 家庭作业id
/// @param url 下载数据地址
+ (NSString *)homeworkPath:(NSString *)homeworkId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kHomework];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", homeworkId]];
     
     return dirPreview;
}

/// svga数据存储地址
/// @param svgaId

+ (NSString *)svgaPath:(NSString *)svgaId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kSVGA];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", svgaId]];
     
     return dirPreview;
}

/// event存储地址
/// @param eventId 事件id

+ (NSString *)eventPath:(NSString *)eventId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kEvent];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", eventId]];
     
     return dirPreview;
}

/// 问题存储路径
/// @param questionId 问题id

+ (NSString *)questionPath:(NSString *)questionId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kQuestion];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", questionId]];
     
     return dirPreview;
}

/// 绘画本存储路径
/// @param pictureId 绘画本id

+ (NSString *)picturePath:(NSString *)pictureId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kPicture];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", pictureId]];
     
     return dirPreview;
}

/// 老师视频存储路径
/// @param teacherVedioId 老师id
/// @param url 视频地址
+ (NSString *)teacherVedioPath:(NSString *)teacherVedioId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kTeacherVideo];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", teacherVedioId]];
     
     return dirPreview;
}

/// 老师提前预习数据存储路径
/// @param teacherFrontId 老师id

+ (NSString *)teacherFrontPath:(NSString *)teacherFrontId   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kTeacherFront];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", teacherFrontId]];
     
     return dirPreview;
}

/// 存储地址
/// @param webMobile 手机号

+ (NSString *)webMobilePath:(NSString *)webMobile   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kWebMobile];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", webMobile]];
     
     return dirPreview;
}

/// ai视频存储路径
/// @param aiPlayer
/// @param url
+ (NSString *)aiPlayerPath:(NSString *)aiPlayer   {
     
    
    NSString *dirPreview = [WMDownload_resource_history_cache_PATH stringByAppendingPathComponent:kAiPlayer];
    dirPreview = [dirPreview stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", aiPlayer]];
     
    return dirPreview;
}

@end
