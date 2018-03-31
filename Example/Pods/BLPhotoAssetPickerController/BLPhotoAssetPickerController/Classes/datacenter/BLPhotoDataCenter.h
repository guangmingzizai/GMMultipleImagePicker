//
//  BLPhotoDataCenter.h
//  BiLin
//
//  Created by devduwan on 15/9/29.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface BLPhotoDataCenter : NSObject

//授权相册功能
+ (void)authorPhotoPermission:(void (^) (bool result))authorBlock;

//获取相册数据
+ (void)fetchPhotoGroupData:(void (^) (NSArray<PHAssetCollection *> *photoGroup))photoGroupBlock;

//绑定相册组cell的数据
+ (void)bindGroupcellData:(PHAssetCollection *)groups withBlock:(void (^) (NSString *title ,NSString *count ,UIImage *posterImage))block;

//转换一个相册的数据源
+ (void)converToPhotoDataSource:(PHAssetCollection *)dataSource withBlock:(void (^) (NSArray<PHAsset *> *))block;
//绑定一个相册相片cell的数据
+ (void)bindPhotoCellData:(PHAsset *)asset withBlock:(void (^) (UIImage *thumbnailImage))block;

// maxSize: (800, 1280), for upload images
+ (void)requestImagesForAssets:(NSArray<PHAsset *> *)assets completionBlock:(void (^) (NSArray<UIImage *> *array))completionBlock requestIDsBlock:(void (^) (NSArray<NSNumber *> *requestArray))requestIDsBlock;
+ (void)requestImagesForAssets:(NSArray<PHAsset *> *)assets maxSize:(CGSize)maxSize completionBlock:(void (^) (NSArray<UIImage *> *array))completionBlock requestIDsBlock:(void (^) (NSArray<NSNumber *> *requestArray))requestIDsBlock;

+ (void)getThumbnailDataFromAssets:(NSArray *)assets WithBlock:(void (^) (NSArray *array))thumbBlock withRequestIDBlock:(void (^) (NSArray *requestArray)) requestIdBlock;

@end
