//
//  BLPhotoAssetPickerController.h
//  BiLin
//
//  Created by devduwan on 15/9/24.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLPhotoAssetNavigationController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BLAssetPhotoCollectionViewCell.h"
#import "BLPhotoDataCenter.h"

@class BLPhotoAssetPickerController;
@protocol BLPhotoAssetPickerControllerDelegate<NSObject>

- (void)photoAssetPickerController:(BLPhotoAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets;
- (void)photoAssetPickerController:(BLPhotoAssetPickerController *)picker didFinishTakingPhoto:(UIImage *)image andPickingAssets:(NSArray *)assets;

@optional

- (void)photoAssetPickerControllerDidCancel:(BLPhotoAssetPickerController *)picker;

@end

@interface BLPhotoAssetPickerController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BLAssetPhotoCollectionViewCellDelegate>

@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property(nonatomic, strong) NSMutableArray *groups;
@property(nonatomic, assign) BOOL cameraEnable;
@property(nonatomic, assign) NSInteger maxSelectionNum;

@property (nonatomic, weak) id <UINavigationControllerDelegate, BLPhotoAssetPickerControllerDelegate> delegate;

@end
