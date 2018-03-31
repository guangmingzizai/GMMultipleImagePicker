//
//  ImageUtils.h
//  HuJiao
//
//  Created by zhengfeng on 13-3-13.
//
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+(UIImage *)resizableImageWithCapInsets2: (UIEdgeInsets) inset fromImage:(UIImage *)image;
+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)imageSize;


+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image longDimension:(CGFloat)longDimension;
+(UIImage *)imageWithImage:(UIImage *)image subToSmallSize:(CGSize)newSize newX:(CGFloat)x newY:(CGFloat)y;
+(UIImage *)imageWithImage:(UIImage *)image subToSmallSize:(CGSize)newSize;
+ (UIImage *)transparentPaddingImageWithImage:(UIImage *)image imageScale:(CGFloat)imageScale padding:(UIEdgeInsets)padding;

//传正常点的尺寸就行了，不需要像素
+ (UIImage *)imageWithBgColor:(UIColor *)bgColor image:(UIImage *)image size:(CGSize)size;
+ (UIImage *)centerImageWithImage:(UIImage *)image toSize:(CGSize)newSize;

+ (UIImage*)scalingAndCroppingToSize:(CGSize)targetSize withImage:(UIImage*)sourceImage;

+ (UIImage *)bilinUploadImage:(UIImage *)image;


+ (UIImage *)sd_cachedImage:(NSURL *)url;
+ (void)sd_buildImageList:(NSArray *)urls complete:(void (^)(NSArray *imageList))block;

@end
