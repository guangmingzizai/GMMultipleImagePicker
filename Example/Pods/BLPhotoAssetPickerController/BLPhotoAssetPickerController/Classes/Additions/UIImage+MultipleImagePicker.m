//
//  UIImage+MultipleImagePicker.m
//  Pods
//
//  Created by wangjianfei on 2016/11/7.
//
//

#import "UIImage+MultipleImagePicker.h"

@implementation UIImage (MultipleImagePicker)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];
}

+ (UIImage *)_imageForName:(NSString *)name inBundle:(NSBundle *)bundle {
    return [UIImage imageForResourcePath:[NSString stringWithFormat:@"BLPhotoAssetPickerController.bundle/%@@2x", name] ofType:@"png" inBundle:bundle];
}

@end
