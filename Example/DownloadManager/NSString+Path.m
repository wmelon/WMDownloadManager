//
//  NSString+Path.m
//  HLDownload
//
//  Created by PCtest on 2020/6/2.
//  Copyright © 2020 PCtest. All rights reserved.
//

#import "NSString+Path.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Path)

#pragma mark - ✋

- (BOOL)exists {
    NSString *extension = self.extension;
    BOOL isDir = (extension || extension.length > 0) ? NO : YES;
    NSFileManager *manager = [NSFileManager defaultManager];

    return [manager fileExistsAtPath:self isDirectory:&isDir];
}

- (NSString *)last {
    return [self lastPathComponent];
}

- (NSString *)name {
    return [[self lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)extension {
    return [self pathExtension];
}

- (NSString *)prefix {
    return [self stringByDeletingLastPathComponent];
}

- (NSString *)namePath {
    return [self stringByDeletingPathExtension];
}

#pragma mark - ⏰

- (BOOL)createFile {
    BOOL exists = [self exists];
    if (exists) return YES;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *extension = [self pathExtension];
    BOOL isDirectory = (extension && extension.length > 0) ? NO : YES;
    BOOL directoryExists = self.prefix.exists;
    
    if (isDirectory) {
        return [manager createDirectoryAtPath:self withIntermediateDirectories:YES attributes:nil error:nil];
    } else if (!directoryExists) {
        [manager createDirectoryAtPath:self.prefix withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [manager createFileAtPath:self contents:nil attributes:nil];
}

#pragma mark -- private method
/// 检查字符串是否为空
/// @param string 字符串
- (BOOL)checkStringIsEmpty {
    if (!self || ![self isKindOfClass:[NSString class]] || self == (id)kCFNull || [self isEqualToString:@""]) {
        return true;
    }
    return false;
}
/// 字符串MD5加密
/// @param string 需要加密的字符串
- (NSString *)MD5 {
    if ([self checkStringIsEmpty]) return @"";
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return [ret lowercaseString];
}

@end
