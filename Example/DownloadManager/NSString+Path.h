//
//  NSString+Path.h
//  HLDownload
//
//  Created by PCtest on 2020/6/2.
//  Copyright © 2020 PCtest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Path)
/// 是否存在
@property (nonatomic, assign, readonly) BOOL exists;
/// 文件名+后缀
@property (nonatomic, copy  , readonly) NSString *last;
/// 文件名
@property (nonatomic, copy  , readonly) NSString *name;
/// 去除最后一个节点
@property (nonatomic, copy  , readonly) NSString *prefix;
/// 去除后缀
@property (nonatomic, copy  , readonly) NSString *namePath;
/// 文件格式
@property (nonatomic, copy  , readonly) NSString *extension;

/// 创建文件
- (BOOL)createFile;

@end
