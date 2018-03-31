//
//  UIImage+MultipleImagePicker.h
//  Pods
//
//  Created by wangjianfei on 2016/11/7.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (MultipleImagePicker)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle;
+ (UIImage *)_imageForName:(NSString *)name inBundle:(NSBundle *)bundle;

@end
