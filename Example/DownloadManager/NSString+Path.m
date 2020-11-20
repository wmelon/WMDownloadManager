//
//  NSString+Path.m
//  HLDownload
//
//  Created by PCtest on 2020/6/2.
//  Copyright © 2020 PCtest. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString (Path)

#pragma mark - ✋

- (BOOL)exists {
    NSString *extension = [self pathExtension];
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

@end
