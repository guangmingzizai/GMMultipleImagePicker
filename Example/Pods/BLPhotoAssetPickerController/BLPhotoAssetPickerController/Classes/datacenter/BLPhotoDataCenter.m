//
//  BLPhotoDataCenter.m
//  BiLin
//
//  Created by devduwan on 15/9/29.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#define IS_IOS8PLUS             ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
#define kThumbnailLength    (UI_SCREEN_WIDTH/3 -36/3)
#define UPLOAD_IMAGE_WIDTH   800
#define UPLOAD_IMAGE_HEIGHT  1280

#import "BLPhotoDataCenter.h"
#import "PHAssetCollection+BLPhotoUtils.h"
#import "ImageUtils.h"
#import "Constants.h"

@implementation BLPhotoDataCenter {
    NSArray *_phAssetsCollectionSubtypes;
    PHFetchOptions *_photoGroupFetchOptions;
    PHFetchOptions *_photoFetchOptions;
    
//dataSource
    NSMutableArray *_photoGroupDatasource;
}

#pragma mark - sharedInstance
+ (instancetype)sharedInstance {
    static BLPhotoDataCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BLPhotoDataCenter alloc] init];
    });
    return sharedInstance;
}

#pragma mark - AuthorPhoto
//授权相册功能
+ (void)authorPhotoPermission:(void (^) (bool result))authorBlock {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status)
    {
        case PHAuthorizationStatusNotDetermined:
            [[BLPhotoDataCenter sharedInstance] requestiOS8AuthorizationStatus:authorBlock];
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            authorBlock(NO);
            break;
        }
        case PHAuthorizationStatusAuthorized:
        default:
        {
            authorBlock(YES);
            break;
        }
    }
}

- (void)requestiOS8AuthorizationStatus:(void (^) (bool result))authorBlock {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        switch (status) {
            case PHAuthorizationStatusAuthorized:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorBlock(YES);
                });
                break;
            }
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    authorBlock(NO);
                });
                break;
            }
        }
    }];
}

#pragma mark - FecthGroupdata

+ (void)fetchPhotoGroupData:(void (^) (NSArray<PHAssetCollection *> *photoGroup))photoGroupBlock {
    [[BLPhotoDataCenter sharedInstance] fetchPhotoGroupiOS8PlusData:photoGroupBlock];
}

- (void) fetchPhotoGroupiOS8PlusData:(void (^) (NSArray *photoGroup)) photoGroupBlock {
    [[BLPhotoDataCenter sharedInstance] bl_setPhAsssetsDefaultOptions];
    
    if (!_photoGroupDatasource) {
        _photoGroupDatasource =[[NSMutableArray alloc]init];
    }else {
        [_photoGroupDatasource removeAllObjects];
    }
    
    for (NSNumber *subNumber in _phAssetsCollectionSubtypes) {
        PHAssetCollectionType type = [PHAssetCollection blPickerAssetCollectionTypeOfSubtype:subNumber.integerValue];
        PHAssetCollectionSubtype subtype = subNumber.integerValue;
        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subtype options:_photoGroupFetchOptions];
        if (fetchResult.count > 0) {
            for (PHAssetCollection *assetCollection in fetchResult) {
                _photoFetchOptions = [PHFetchOptions new];
                _photoFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:_photoFetchOptions];
                if(result.count > 0) {
                    [_photoGroupDatasource addObject:assetCollection];
                }
            }
        }
    }
    photoGroupBlock(_photoGroupDatasource);
}

#pragma mark - PHASSET Utils
- (void) bl_setPhAsssetsDefaultOptions {
    _phAssetsCollectionSubtypes =
    @[[NSNumber numberWithInt:PHAssetCollectionSubtypeSmartAlbumUserLibrary],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumMyPhotoStream],
      [NSNumber numberWithInt:PHAssetCollectionSubtypeAlbumRegular]];
    
    _photoGroupFetchOptions = [PHFetchOptions new];
    _photoGroupFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"estimatedAssetCount" ascending:NO]];
}

#pragma mark - 绑定相册组cell的数据

+ (void)bindGroupcellData:(PHAssetCollection *)groups withBlock:(void (^) (NSString *title ,NSString *count ,UIImage *posterImage))block {
    [[BLPhotoDataCenter sharedInstance] bindiOS8Plus:groups withBlock:block];
}

- (void)bindiOS8Plus:(PHAssetCollection *)phCollection withBlock:(void (^) (NSString *title ,NSString *count ,UIImage *posterImage))block {
    _photoFetchOptions = [PHFetchOptions new];
    _photoFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:phCollection options:_photoFetchOptions];
    
    PHAsset *asset = [result firstObject];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    NSInteger scale = [UIScreen mainScreen].scale;
    CGSize coverSize = CGSizeMake(kThumbnailLength * scale, kThumbnailLength * scale);
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    NSString *countStr = [formatter stringFromNumber:[NSNumber numberWithUnsignedInteger:result.count]];
    NSString *titleStr = phCollection.localizedTitle;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:coverSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        if (image) {
            block(titleStr, countStr, image);
        }
    }];
}

#pragma mark - converToPhotoDataSource
//转换一个相册的数据源
+ (void)converToPhotoDataSource:(PHAssetCollection *)dataSource withBlock:(void (^) (NSArray<PHAsset *> *))block {
    NSMutableArray *convertSource = [[NSMutableArray alloc] init];
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:dataSource options:fetchOptions];
    for (int i = 0; i<result.count; i++) {
        PHAsset *asset = [result objectAtIndexedSubscript:i];
        [convertSource addObject:asset];
    }
    block(convertSource);
}

//绑定一个相册相片cell的数据
+ (void)bindPhotoCellData:(PHAsset *)asset withBlock:(void (^) (UIImage *thumbnailImage))block {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(kThumbnailLength*2, kThumbnailLength*2) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result){
            block(result);
        }
    }];
}

+ (void)requestImagesForAssets:(NSArray<PHAsset *> *)assets completionBlock:(void (^) (NSArray<UIImage *> *array))completionBlock requestIDsBlock:(void (^) (NSArray<NSNumber *> *requestArray))requestIDsBlock {
    [self requestImagesForAssets:assets maxSize:CGSizeMake(UPLOAD_IMAGE_WIDTH, UPLOAD_IMAGE_HEIGHT) completionBlock:completionBlock requestIDsBlock:requestIDsBlock];
}

+ (void)requestImagesForAssets:(NSArray<PHAsset *> *)assets maxSize:(CGSize)maxSize completionBlock:(void (^) (NSArray<UIImage *> *array))completionBlock requestIDsBlock:(void (^) (NSArray<NSNumber *> *requestArray))requestIDsBlock {
    NSMutableArray<UIImage *> *imageArray = [NSMutableArray array];
    NSMutableArray<NSNumber *> *requestArray = [NSMutableArray array];
    NSMutableDictionary *assetImageDic = [NSMutableDictionary dictionary];
    for (volatile int i = 0; i < assets.count; i ++) {
        PHAsset *asset = [assets objectAtIndex:i];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        
        CGSize targetSize = [[BLPhotoDataCenter sharedInstance] caculateTargetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) maxWidth:maxSize.width maxHeight:maxSize.height];
        PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                assetImageDic[@(i)] = result;
                if (assetImageDic.count == assets.count) {
                    for (int j = 0; j < assets.count; j++) {
                        [imageArray addObject:assetImageDic[@(j)]];
                    }
                    completionBlock(imageArray);
                }
            }
        }];
        [requestArray addObject:[NSNumber numberWithInt:(requestID)]];
        if (requestArray.count == assets.count) {
            requestIDsBlock(requestArray);
        }
    }
}

+ (void)getThumbnailDataFromAssets:(NSArray *)assets WithBlock:(void (^) (NSArray *array))thumbBlock withRequestIDBlock:(void (^) (NSArray *requestArray))requestIdBlock {
    NSMutableArray *thumbArray = [NSMutableArray array];
    NSMutableArray *requestArray = [NSMutableArray array];
    NSMutableDictionary *assetImageDic = [NSMutableDictionary dictionary];
    
    for (volatile int i = 0; i < assets.count; i ++) {
        PHAsset *asset = [assets objectAtIndex:i];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        
        PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:(PHAsset *)asset targetSize:[[BLPhotoDataCenter sharedInstance] caculateTargetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                assetImageDic[@(i)] = result;
                if (assetImageDic.count == assets.count) {
                    for (int j = 0; j < assets.count; j++) {
                        [thumbArray addObject:assetImageDic[@(j)]];
                    }
                    thumbBlock(thumbArray);
                }
            }
        }];
        [requestArray addObject:[NSNumber numberWithInt:(requestID)]];
        if (requestArray.count == assets.count) {
            requestIdBlock(requestArray);
        }
    }
}

- (CGSize)caculateTargetSize:(CGSize )fromSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    CGSize size = fromSize;
    if ((size.width > maxWidth) || ((size.height) > maxHeight)) {
        if ((size.width / size.height) > 1) {
            // 横图
            CGFloat scale = MIN((maxWidth / size.height), (maxHeight / size.width));
            size = CGSizeMake(size.width * scale, size.height * scale);
        } else {
            // 竖图
            CGFloat scale = MIN((maxWidth / size.width), (maxHeight / size.height));
            size = CGSizeMake(size.width * scale, size.height * scale);
        }
    }
    return size;
}

- (CGSize)caculateTargetSize:(CGSize )fromSize {
    CGSize size = fromSize;
    if ((size.width > UPLOAD_IMAGE_WIDTH) || ((size.height) > UPLOAD_IMAGE_HEIGHT)) {
        if ((size.width / size.height) > 1) {
            // 横图
            CGFloat scale = MIN((UPLOAD_IMAGE_WIDTH / size.height), (UPLOAD_IMAGE_HEIGHT / size.width));
            size = CGSizeMake(size.width * scale, size.height * scale);
        } else {
            // 竖图
            CGFloat scale = MIN((UPLOAD_IMAGE_WIDTH / size.width), (UPLOAD_IMAGE_HEIGHT / size.height));
            size = CGSizeMake(size.width * scale, size.height * scale);
        }
    }
    return size;
}

@end
