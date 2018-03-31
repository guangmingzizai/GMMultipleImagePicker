//
//  NSFileManager+GMAdditions.m
//  Pods
//
//  Created by wangjianfei on 2016/11/8.
//
//

#import "NSFileManager+GMAdditions.h"

@implementation NSFileManager (GMAdditions)

+ (BOOL)gm_addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    else {
        NSLog(@"Error setting skip backup attribute: file not found");
        return NO;
    }
}

+ (void)gm_deleteAllFilesOfDirectory:(NSString *)dir {
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSArray *fileList = [fileManager contentsOfDirectoryAtPath:dir error:nil];
  for (NSString *fileName in fileList) {
    [fileManager removeItemAtPath:[dir stringByAppendingPathComponent:fileName] error:nil];
  }
}

+ (unsigned long long)gm_fileSizeAtPath:(NSString *)path
{
  unsigned long long size = 0;
  
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  BOOL isDir;
  if ( [fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir )
  {
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
      NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
      
      BOOL isDir;
      if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
      {
        NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
        size += fileAttributeDic.fileSize;
      }
      else
      {
        [self gm_fileSizeAtPath:fullPath];
      }
    }
    
  }
  else
  {
    NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:path error:nil];
    size += fileAttributeDic.fileSize;
  }
  
  return size;
}


@end
