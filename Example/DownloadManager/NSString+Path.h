//
//  NSString+Path.h
//  HLDownload
//
//  Created by PCtest on 2020/6/2.
//  Copyright © 2020 PCtest. All rights reserved.
//

#import <Foundation/Foundation.h>

/// filePath如：/Users/sper/Library/da762db317032bdd147a028ec9fe55c7.zip

@interface NSString (Path)
/// 是否存在
@property (nonatomic, assign, readonly) BOOL exists;

/// 文件名+后缀   da762db317032bdd147a028ec9fe55c7.zip
@property (nonatomic, copy  , readonly) NSString *last;

/// 文件名 ：da762db317032bdd147a028ec9fe55c7
@property (nonatomic, copy  , readonly) NSString *name;

/// 去除最后一个节点:  /Users/sper/Library
@property (nonatomic, copy  , readonly) NSString *prefix;

/// 去除后缀  : /Users/sper/Library/da762db317032bdd147a028ec9fe55c7
@property (nonatomic, copy  , readonly) NSString *namePath;

/// 文件格式  : zip
@property (nonatomic, copy  , readonly) NSString *extension;

/// 创建文件
- (BOOL)createFile;

/// 检查字符串是否为空
- (BOOL)checkStringIsEmpty;

/// 字符串MD5加密
- (NSString *)MD5;

@end
