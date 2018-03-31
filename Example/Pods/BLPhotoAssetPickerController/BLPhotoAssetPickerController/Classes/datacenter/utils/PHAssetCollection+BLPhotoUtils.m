//
//  PHAssetCollection+BLPhotoUtils.m
//  BiLin
//
//  Created by devduwan on 15/9/29.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "PHAssetCollection+BLPhotoUtils.h"

@implementation PHAssetCollection (BLPhotoUtils)

+ (PHAssetCollectionType)blPickerAssetCollectionTypeOfSubtype:(PHAssetCollectionSubtype)subtype
{
    return (subtype >= PHAssetCollectionSubtypeSmartAlbumGeneric) ? PHAssetCollectionTypeSmartAlbum : PHAssetCollectionTypeAlbum;
}

- (NSInteger)blPikcerCountOfAssetsFetchedWithOptions:(PHFetchOptions *)fetchOptions
{
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self options:fetchOptions];
    return result.count;
}

@end
