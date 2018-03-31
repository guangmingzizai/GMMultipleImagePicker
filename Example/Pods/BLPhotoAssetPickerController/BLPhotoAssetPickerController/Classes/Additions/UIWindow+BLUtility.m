//
//  UIWindow+BLUtility.m
//  BiLin
//
//  Created by 柬斐 王 on 15/3/11.
//  Copyright (c) 2015年 inbilin. All rights reserved.
//

#import "UIWindow+BLUtility.h"

@implementation UIWindow (BLUtility)

+ (UIWindow *)bl_mainWindow {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    for (NSInteger i = (windows.count - 1); i >= 0; i--) {
        UIWindow *window = [windows objectAtIndex:i];
        if (!window.hidden && CGSizeEqualToSize(screenSize, window.bounds.size)) {
            return window;
        }
    }
    
    return [[UIApplication sharedApplication] keyWindow];
}

+ (UIWindow *)bl_appWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

@end
