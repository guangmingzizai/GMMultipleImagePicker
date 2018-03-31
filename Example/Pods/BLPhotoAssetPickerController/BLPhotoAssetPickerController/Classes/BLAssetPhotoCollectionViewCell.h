//
//  BLAssetPhotoCollectionViewCell.h
//  BiLin
//
//  Created by devduwan on 15/9/28.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@protocol BLAssetPhotoCollectionViewCellDelegate <NSObject>

- (NSInteger)maxSeletionNum;
- (void)putCellSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeCellSelectedAtIndexPath:(NSIndexPath *)indexPath;

@end

typedef NS_ENUM(NSInteger, BLPhotoChoose) {
    BLPhotoChooseUnSelected,
    BLPhotoChooseSelectd
};

@interface BLAssetPhotoCollectionViewCell : UICollectionViewCell

@property(nonatomic, assign)BLPhotoChoose chooseStatus;
@property(nonatomic, strong)UIImageView *picImageView;
@property(nonatomic, strong)UIView *chooseView;
@property(nonatomic, strong)UIImageView *chooseImageView;

@property(nonatomic, strong)NSIndexPath *indexPath;
@property(nonatomic, assign)id<BLAssetPhotoCollectionViewCellDelegate> collectionViewDelegate;

- (void)bind:(NSObject *)dataSource;
- (void)changeSelectPhoto;

@end
