//
//  PHAssetCollection+BLPhotoUtils.h
//  BiLin
//
//  Created by devduwan on 15/9/29.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAssetCollection (BLPhotoUtils)

+ (PHAssetCollectionType)blPickerAssetCollectionTypeOfSubtype:(PHAssetCollectionSubtype)subtype;
- (NSInteger)blPikcerCountOfAssetsFetchedWithOptions:(PHFetchOptions *)fetchOptions;

@end
