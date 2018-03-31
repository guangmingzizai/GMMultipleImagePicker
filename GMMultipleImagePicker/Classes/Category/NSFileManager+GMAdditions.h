//
//  NSFileManager+GMAdditions.h
//  Pods
//
//  Created by wangjianfei on 2016/11/8.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (GMAdditions)

+ (BOOL)gm_addSkipBackupAttributeToItemAtPath:(NSString *) filePathString;
+ (void)gm_deleteAllFilesOfDirectory:(NSString *)dir;
+ (unsigned long long)gm_fileSizeAtPath:(NSString *)path;

@end
