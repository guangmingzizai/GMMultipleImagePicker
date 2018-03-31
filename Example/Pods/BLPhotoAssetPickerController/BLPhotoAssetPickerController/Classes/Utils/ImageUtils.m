//
//  ImageUtils.m
//  HuJiao
//
//  Created by zhengfeng on 13-3-13.
//
//

#import "ImageUtils.h"
#import "SDWebImageManager.h"

#define UPLOAD_IMAGE_WIDTH   800
#define UPLOAD_IMAGE_HEIGHT  1280

@implementation ImageUtils
+(UIImage *)resizableImageWithCapInsets2: (UIEdgeInsets) inset fromImage:(UIImage *)image
{

    return [image stretchableImageWithLeftCapWidth:inset.left topCapHeight:inset.top];
}

+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)imageSize {
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



+(UIImage *)imageWithImage:(UIImage *)image subToSmallSize:(CGSize)newSize
{
    CGRect smallBounds = CGRectMake(0, 0, newSize.width, newSize.height);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, smallBounds);
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}


+(UIImage *)imageWithImage:(UIImage *)image subToSmallSize:(CGSize)newSize newX:(CGFloat)x newY:(CGFloat)y
{
    CGRect smallBounds = CGRectMake(x, y, newSize.width, newSize.height);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, smallBounds);
    image = [UIImage imageWithCGImage:subImageRef scale:1.0 orientation:image.imageOrientation];
    UIGraphicsBeginImageContext(smallBounds.size);
    [image drawInRect:smallBounds];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, smallBounds, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}

+ (UIImage *)centerImageWithImage:(UIImage *)image toSize:(CGSize)newSize {
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    CGRect centerRect;
    if (width <= height) {
        centerRect = CGRectMake(0, (height - width) / 2, width, width);
    } else {
        centerRect = CGRectMake((width - height) / 2, 0, height, height);
    }
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, centerRect);
    image = [UIImage imageWithCGImage:subImageRef scale:1.0 orientation:image.imageOrientation];
    CGImageRelease(subImageRef);
    
    if (image) {
        UIGraphicsBeginImageContext(newSize);
        //    CGContextRef context = UIGraphicsGetCurrentContext();
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        //    CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), subImageRef);
        //    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
        UIImage* smallImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return smallImage;
    } else {
        return nil;
    }
}

+ (UIImage *)transparentPaddingImageWithImage:(UIImage *)image imageScale:(CGFloat)imageScale padding:(UIEdgeInsets)padding {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat targetWidth = imageWidth + (padding.left + padding.right) * imageScale;
    CGFloat targetHeight = imageHeight + (padding.top + padding.bottom) * imageScale;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [image drawInRect:CGRectMake(padding.left * imageScale, padding.top * imageScale, imageWidth, imageHeight)];
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return targetImage;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    if (image.size.width == newSize.width && image.size.height == newSize.height) {
        return  image;
    }
    
    // Create a graphics image context
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image longDimension:(CGFloat)longDimension {
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat aspectRatio = width / height;
    
    if (width >= height) {
        width = longDimension;
        height = width / aspectRatio;
    } else {
        height = longDimension;
        width = height * aspectRatio;
    }
    return [self imageWithImage:image scaledToSize:CGSizeMake(width, height)];
}

+ (UIImage *)imageWithBgColor:(UIColor *)bgColor image:(UIImage *)image size:(CGSize)size {
    CGSize imageSize = image.size;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    [image drawInRect:CGRectMake((size.width - imageSize.width) / 2, (size.height - imageSize.height) / 2, imageSize.width, imageSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//剪裁&压缩图片
+ (UIImage*)scalingAndCroppingToSize:(CGSize)targetSize withImage:(UIImage*)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    //剪裁点的位置，以3*2长方形剪裁为2*2正方形为例，截取image中心部分，剪切点为（0，0.5）
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        //compress scale
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        //set scaleFactoras lesser scale,fit lesser scale
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        
        //reset the target size with the new scale factor
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // get cropping point
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    //corpping image to special rectangle
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)bilinUploadImage:(UIImage *)image {
    CGSize size = image.size;
    if ((size.width > UPLOAD_IMAGE_WIDTH) || ((size.height) > UPLOAD_IMAGE_HEIGHT)) {
        if ((size.width / size.height) > 1) {
            // 横图
            CGFloat scale = MIN((UPLOAD_IMAGE_WIDTH / size.height), (UPLOAD_IMAGE_HEIGHT / size.width));
            image = [ImageUtils imageWithImage:image scaledToSize:CGSizeMake(size.width * scale, size.height * scale)];
            NSLog(@"图片缩放比例%.2f-缩放后尺寸%@-原始尺寸%@", scale, NSStringFromCGSize(image.size), NSStringFromCGSize(size));
        } else {
            // 竖图
            CGFloat scale = MIN((UPLOAD_IMAGE_WIDTH / size.width), (UPLOAD_IMAGE_HEIGHT / size.height));
            image = [ImageUtils imageWithImage:image scaledToSize:CGSizeMake(size.width * scale, size.height * scale)];
            NSLog(@"图片缩放比例%.2f-缩放后尺寸%@-原始尺寸%@", scale, NSStringFromCGSize(image.size), NSStringFromCGSize(size));
        }
    }
    
    return image;
}

+ (UIImage *)sd_cachedImage:(NSURL *)url {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:key];
    return image;
}

+ (void)sd_buildImageList:(NSArray *)urls complete:(void (^)(NSArray *imageList))block {
    if (urls.count == 0) {
        block(nil);
        return;
    }
    NSMutableArray *imageList = [NSMutableArray arrayWithArray:urls];
    __block NSUInteger remain = urls.count;
    [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SDWebImageManager sharedManager] loadImageWithURL:obj
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                      if (image) {
                                                          imageList[idx] = image;
                                                          remain--;
                                                          if (remain == 0) {
                                                              block(imageList);
                                                          }
                                                      }
                                                      else {
                                                          block(nil);
                                                      }
                                                  }];
    }];
}

@end
