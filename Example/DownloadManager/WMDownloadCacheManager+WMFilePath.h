//
//  WMDownloadCacheManager+WMFilePath.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/11/20.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMDownloadCacheManager (WMFilePath)

/// 预习课存储地址
/// @param lessonId 课程id
/// @param resourceId 源数据id
/// @param version 版本号
/// @param url 下载地址
+ (NSString *)previewPathWith:(NSString *)lessonId resourceId:(NSString *)resourceId version:(NSString *)version;

/// 家庭作业存储地址
/// @param homeworkId 家庭作业id
/// @param url 下载数据地址
+ (NSString *)homeworkPath:(NSString *)homeworkId  ;

/// svga数据存储地址
/// @param svgaId
/// @param url 下载地址
+ (NSString *)svgaPath:(NSString *)svgaId  ;

/// event存储地址
/// @param eventId 事件id
/// @param url 下载地址
+ (NSString *)eventPath:(NSString *)eventId  ;

/// 问题存储路径
/// @param questionId 问题id
/// @param url 下载地址
+ (NSString *)questionPath:(NSString *)questionId  ;

/// 绘画本存储路径
/// @param pictureId 绘画本id
/// @param url 下载地址
+ (NSString *)picturePath:(NSString *)pictureId  ;

/// 老师视频存储路径
/// @param teacherVedioId 老师id
/// @param url 视频地址
+ (NSString *)teacherVedioPath:(NSString *)teacherVedioId  ;

/// 老师提前预习数据存储路径
/// @param teacherFrontId 老师id
/// @param url 下载地址
+ (NSString *)teacherFrontPath:(NSString *)teacherFrontId  ;

/// 存储地址
/// @param webMobile 手机号
/// @param url 下载地址
+ (NSString *)webMobilePath:(NSString *)webMobile  ;

/// ai视频存储路径
/// @param aiPlayer
/// @param url
+ (NSString *)aiPlayerPath:(NSString *)aiPlayer  ;

@end

NS_ASSUME_NONNULL_END
