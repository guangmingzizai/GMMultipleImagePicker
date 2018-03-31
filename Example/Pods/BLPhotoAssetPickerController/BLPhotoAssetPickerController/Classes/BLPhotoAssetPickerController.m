//
//  BLPhotoAssetPickerController.m
//  BiLin
//
//  Created by devduwan on 15/9/24.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLPhotoAssetPickerController.h"
#import "BLAssetSwitch.h"
#import "BLAssetCameraCollectionViewCell.h"
#import "BLAssetGroupTableViewCell.h"
#import "BLPhotoDataCenter.h"
#import "BLPhotoUtils.h"
#import "POPSpringAnimation.h"
#import "MWPhotoBrowser.h"
#import "MBProgressHUD+Add.h"
#import "Constants.h"
#import <Masonry/Masonry.h>
#import "UIImage+MultipleImagePicker.h"

@interface BLPhotoAssetPickerController () <MWPhotoBrowserDelegate>

@end

@implementation BLPhotoAssetPickerController {
    UICollectionViewFlowLayout *_photoLayout;
    UICollectionView *_photoCollectionView;
    NSMutableArray *_collectionDataSource;
    
    UILabel *_previewLabel;
    UILabel *_finishLabel;
    UILabel *_choseCountLabel;
    
    UIView *_coverShadowView;
    UITableView *_photoGroupTableView;
    NSMutableArray *_tableDataSource;
    
    UIView *_bottomBg;
    
    BLAssetSwitch *_assetSwitch;
//    选中的index集合
    NSMutableArray *_chooseIndexArray;
    
//    查看大图与预览
    NSMutableArray *_originalRepresentationPhotos;
    NSMutableDictionary *_originalRepresentationPhotoIndexToPhotoIndex;//大图Index:小图index
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    self.cameraEnable = YES;
    self.maxSelectionNum = 9;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iOS_Version >= 7.0) {
        //        ios7  高度显示  兼容性问题
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self setUpUI];
    [self setPhotoGroupDatasoureAndPhotoPreviewDatasource];
}

#pragma mark - UI

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationAttachView];
    [self setPhotoCollectionViewPreview];
    [self setBottomUI];
    [self setGroupTableViewAndShadowView];
}

- (void)setNavigationAttachView {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithImage:[UIImage _imageForName:@"custom_nav_back_icon" inBundle:[NSBundle bundleForClass:[self class]]] style:UIBarButtonItemStylePlain target:self action:@selector(cancelChoose)];
    self.navigationItem.leftBarButtonItem = cancelButton;
  
    NSString *title = @"longlong album name";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGRect titleRect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    _assetSwitch = [[BLAssetSwitch alloc]initWithFrame:CGRectMake(0, 0, titleRect.size.width +17, 44)];
    [_assetSwitch addTarget:self action:@selector(bl_switchStatusClass:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _assetSwitch;
}

- (void)setPhotoCollectionViewPreview {
    _photoLayout = [[UICollectionViewFlowLayout alloc]init];
    _photoLayout.itemSize = CGSizeMake(UI_SCREEN_WIDTH/3-36/3, UI_SCREEN_WIDTH/3-36/3);
    CGFloat paddingX = 0;
    CGFloat paddingY = 0;
    _photoLayout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
    _photoLayout.minimumLineSpacing = 6;
    _photoLayout.minimumInteritemSpacing = 6;
    
    _photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_photoLayout];
    _photoCollectionView.dataSource = self;
    _photoCollectionView.delegate = self;
    _photoCollectionView.backgroundColor = [UIColor clearColor];
    _photoCollectionView.contentInset = UIEdgeInsetsMake(12, 12, 56, 12);
    [self.view addSubview:_photoCollectionView];
    [_photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    //regist collectionviewcell
    [_photoCollectionView registerClass:[BLAssetPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCollectionCell"];
    [_photoCollectionView registerClass:[BLAssetCameraCollectionViewCell class] forCellWithReuseIdentifier:@"reuseDefault"];
}

- (void)setBottomUI {
    _bottomBg = [[UIView alloc]init];
    _bottomBg.backgroundColor = [UIColor whiteColor];
    _bottomBg.alpha = 0.95;
    [self.view addSubview:_bottomBg];
    [_bottomBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.bottom.mas_equalTo(IS_IPHONE_X ? -34 : 0);
        make.height.mas_equalTo(44);
    }];
    
    _previewLabel = [[UILabel alloc]init];
    _previewLabel.text = NSLocalizedString(@"预览", Nil);
    _previewLabel.backgroundColor = [UIColor clearColor];
    _previewLabel.font = [UIFont systemFontOfSize:16];
    _previewLabel.textColor = UIColorFromRGB(0x7969a6);
    
    _previewLabel.userInteractionEnabled = NO;
    _previewLabel.alpha = 0.3;
    [_previewLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewChoosedPhoto)]];
    
    [_bottomBg addSubview:_previewLabel];
    [_previewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    _finishLabel = [[UILabel alloc]init];
    _finishLabel.text = NSLocalizedString(@"完成", Nil);
    _finishLabel.backgroundColor = [UIColor clearColor];
    _finishLabel.font = [UIFont systemFontOfSize:16];
    _finishLabel.textColor = UIColorFromRGB(0xffc200);
    _finishLabel.textAlignment = NSTextAlignmentLeft;
    [_bottomBg addSubview:_finishLabel];
    CGSize size = [_finishLabel.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    [_finishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(4+size.width,44));
    }];
    
    _finishLabel.alpha = 0.3;
    _finishLabel.userInteractionEnabled = YES;
    [_finishLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(finishChoosePhoto)]];
    
    _choseCountLabel = [[UILabel alloc]init];
    _choseCountLabel.backgroundColor = UIColorFromRGB(0xffc200);
    _choseCountLabel.textAlignment = NSTextAlignmentCenter;
    _choseCountLabel.text = @"0";
    _choseCountLabel.textColor = [UIColor whiteColor];
    _choseCountLabel.font = [UIFont systemFontOfSize:16];
    _choseCountLabel.layer.masksToBounds = YES;
    _choseCountLabel.layer.cornerRadius = 11;
    
    _choseCountLabel.hidden = YES;
    [_bottomBg addSubview:_choseCountLabel];
    [_choseCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_bottomBg.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.right.mas_equalTo(_finishLabel.mas_left).with.offset(-7);
    }];
    _choseCountLabel.userInteractionEnabled = YES;
    [_choseCountLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(finishChoosePhoto)]];
 
    
}

- (void)setGroupTableViewAndShadowView {
    _coverShadowView = [[UIView alloc]init];
    _coverShadowView.backgroundColor = [UIColor blackColor];
    _coverShadowView.alpha = 0;
    _coverShadowView.hidden = YES;
    [self.view addSubview:_coverShadowView];
    [_coverShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    _coverShadowView.userInteractionEnabled = YES;
    [_coverShadowView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(coverViewSelectedChangeSwitch)]];
    
    _photoGroupTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _photoGroupTableView.delegate = self;
    _photoGroupTableView.dataSource = self;
    _photoGroupTableView.backgroundColor = [UIColor clearColor];
    _photoGroupTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _photoGroupTableView.bounces = NO;
    [self.view addSubview:_photoGroupTableView];
    [_photoGroupTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(340);
    }];
    _photoGroupTableView.hidden = YES;
    
}

#pragma mark - UI-Action
- (void)cancelChoose {
    [BLPhotoUtils setWillUseCount:0];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(photoAssetPickerControllerDidCancel:)]) {
        [self.delegate photoAssetPickerControllerDidCancel:self];
    }
}

- (void)bl_switchStatusClass:(BLAssetSwitch *)assetSwitch {
    if (assetSwitch.selectedOption == BLAssetSwitchPhotoPreviewAll) {
        [UIView animateWithDuration:0.15 animations:^{
            _photoGroupTableView.alpha = 0;
            [_photoGroupTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                make.top.mas_equalTo(-340);
                if (_tableDataSource.count * 65 > 340) {
                    make.height.mas_equalTo(340);
                }else {
                    make.height.mas_equalTo(_tableDataSource.count * 65);
                }
            }];
        } completion:^(BOOL finished) {
            _photoGroupTableView.hidden = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2 animations:^{
                    _coverShadowView.alpha = 0.05;
                } completion:^(BOOL finished) {
                    _coverShadowView.hidden =YES;
                }];

            });
        }];
        
    }else {
        _coverShadowView.hidden = NO;
        _photoGroupTableView.alpha = 0;
        [_photoGroupTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(-340);
            make.height.mas_equalTo(340);
        }];
        [UIView animateWithDuration:0.15 animations:^{
            _coverShadowView.alpha = 0.5;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2 animations:^{
                    _photoGroupTableView.hidden = NO;
                    _photoGroupTableView.alpha = 1;
                    [_photoGroupTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.mas_equalTo(0);
                        make.top.mas_equalTo(0);
                        if (_tableDataSource.count * 65 > 340) {
                            make.height.mas_equalTo(340);
                        }else {
                            make.height.mas_equalTo(_tableDataSource.count * 65);
                        }
                    }];
                }];
 
            });
        }];
    }
}

- (void)finishChoosePhoto {
    if ([BLPhotoUtils getWillUseCount] + 0 == 0) {
        return;
    };
    
    [BLPhotoUtils setUseCount:[BLPhotoUtils getUseCount] +[BLPhotoUtils getWillUseCount]];
    [BLPhotoUtils setWillUseCount:0];
    
    BLPhotoAssetPickerController *pickNav = (BLPhotoAssetPickerController *)self.navigationController;
    if ([self.delegate respondsToSelector:@selector(photoAssetPickerController:didFinishPickingAssets:)]) {
        NSMutableArray *backAsset = [NSMutableArray array];
        for (int i = 0; i < _chooseIndexArray.count; i++) {
            [backAsset addObject:[_collectionDataSource objectAtIndex:((NSIndexPath *)_chooseIndexArray[i]).row - (self.cameraEnable ? 1 : 0)]];
        }
        [self.delegate photoAssetPickerController:self didFinishPickingAssets:backAsset];
    }
}

- (void)previewChoosedPhoto {
    [self bl_browseOriginalRepresentationPhotos:YES fromIndex:0];
}

- (void)coverViewSelectedChangeSwitch {
    [_assetSwitch changeSelectStatus];
}

#pragma mark - PhotoGroupAndPhotoPreview Datasource

- (void)setPhotoGroupDatasoureAndPhotoPreviewDatasource {
    _tableDataSource = [NSMutableArray array];
    _collectionDataSource = [NSMutableArray array];
    _chooseIndexArray = [NSMutableArray array];
   
    //授权
    [BLPhotoDataCenter authorPhotoPermission:^(bool result) {
        if (result) {
            [BLPhotoDataCenter fetchPhotoGroupData:^(NSArray<PHAssetCollection *> *photoGroup) {
                _tableDataSource = [NSMutableArray arrayWithArray:photoGroup];
                [_photoGroupTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.mas_equalTo(0);
                    make.top.mas_equalTo(-340);
                    if (_tableDataSource.count * 65 > 340) {
                        make.height.mas_equalTo(340);
                    }else {
                        make.height.mas_equalTo(_tableDataSource.count * 65);
                    }
                }];
                [_photoGroupTableView reloadData];

                [BLPhotoDataCenter converToPhotoDataSource:[_tableDataSource firstObject] withBlock:^(NSArray<PHAsset *> * array) {
                    _collectionDataSource = [NSMutableArray arrayWithArray:array];
                    _bottomBg.hidden = NO;
                    [_photoCollectionView reloadData];
                }];
            }];
        }else {
            [self showNotAllowedUI];
        }
    }];
    
}

- (void)showNotAllowedUI
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
        
    self.title              = nil;
        
    UIImageView *padlock    = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ZYQAssetPicker.Bundle/Images/AssetsPickerLocked@2x.png"]]];
    padlock.translatesAutoresizingMaskIntoConstraints = NO;
        
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
        
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
        
    title.text              = NSLocalizedString(@"此应用无法使用您的照片或视频。", nil);
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"你可以在「隐私设置-照片」开启权限。", nil);
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
        
    [title sizeToFit];
    [message sizeToFit];
        
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:padlock];
    [centerView addSubview:title];
    [centerView addSubview:message];
        
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);
        
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:padlock attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
        
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
   
    _bottomBg.hidden = YES;
    _photoCollectionView.backgroundView = backgroundView;
    [_photoCollectionView reloadData];
}

#pragma mark - UICollection Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.cameraEnable) {
        BLAssetCameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseDefault" forIndexPath:indexPath];
        if (!cell) {
            cell = [[BLAssetCameraCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH/3-36/3, UI_SCREEN_WIDTH/3-36/3)];
        }
        if ([BLPhotoUtils getUseCount] +[BLPhotoUtils getWillUseCount] == self.maxSelectionNum) {
            cell.cameraImageView.alpha = 0.5;
            cell.cameraLabel.alpha = 0.5;
        }else {
            cell.cameraImageView.alpha = 1;
            cell.cameraLabel.alpha = 1;
        }
        return cell;
    }else {
        BLAssetPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCollectionCell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[BLAssetPhotoCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH/3-36/3, UI_SCREEN_WIDTH/3-36/3)];
        }
        cell.indexPath = indexPath;
        cell.collectionViewDelegate = self;
        if ([self indexIsSelected:indexPath]) {
            cell.chooseStatus = BLPhotoChooseSelectd;
            cell.chooseImageView.image = [UIImage _imageForName:@"status_pic_selected" inBundle:[NSBundle bundleForClass:[self class]]];
        }else {
            cell.chooseStatus = BLPhotoChooseUnSelected;
            cell.chooseImageView.image = [UIImage _imageForName:@"status_pic_unselect" inBundle:[NSBundle bundleForClass:[self class]]];
        }
        [cell bind:[_collectionDataSource objectAtIndex:indexPath.row - (self.cameraEnable ? 1 : 0)]];
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //授权没通过
    if (_bottomBg.hidden == YES) {
        return 0;
    }else {
        return _collectionDataSource.count + (self.cameraEnable ? 1 : 0);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.cameraEnable) {
        BLAssetCameraCollectionViewCell *cell = (BLAssetCameraCollectionViewCell*)[_photoCollectionView cellForItemAtIndexPath:indexPath];
        cell.coverView.hidden = NO;
        
#if TARGET_IPHONE_SIMULATOR
        [MBProgressHUD showTip:LocalizedString(@"Camera not available on simulator")];
#else
        [self checkCameraPermissions:^(BOOL granted) {
            if (granted) {
                [self openCamera];
            } else {
                [MBProgressHUD showTip:LocalizedString(@"Camera permissions not granted")];
            }
        }];
#endif
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            cell.coverView.hidden = YES;
        });
    } else {
        [self bl_browseOriginalRepresentationPhotos:NO fromIndex:indexPath.item - (self.cameraEnable ? 1 : 0)];
    }
}

- (BOOL)indexIsSelected:(NSIndexPath *)indexPath {
    if (_chooseIndexArray!=NULL && _chooseIndexArray.count > 0) {
        for (int i = 0; i< _chooseIndexArray.count; i ++) {
            if (((NSIndexPath *)[_chooseIndexArray objectAtIndex:i]).row == indexPath.row) {
                return true;
            }
        }
    }
    return false;
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLAssetGroupTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"assertTableviewCell"];
    if (!cell) {
        cell = [[BLAssetGroupTableViewCell alloc]initWithFrame:CGRectMake(0, 0, 65, 65)];
    }
    [cell bind:[_tableDataSource objectAtIndex:indexPath.row] atIndex:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [BLPhotoDataCenter converToPhotoDataSource:[_tableDataSource objectAtIndex:indexPath.row] withBlock:^(NSArray * array) {
        [BLPhotoUtils setWillUseCount:0];
        [_chooseIndexArray removeAllObjects];
        _collectionDataSource = [NSMutableArray arrayWithArray:array];
        [_photoCollectionView reloadData];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLAssetGroupTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    _assetSwitch.titleLabel.text = cell.groupLabel.text;
    [_assetSwitch changeSelectStatus];
    [_assetSwitch updateConstraintsWithString:cell.groupLabel.text];
    
    _choseCountLabel.text = @"0";
    _choseCountLabel.hidden = YES;
    _finishLabel.userInteractionEnabled = NO;
    _finishLabel.alpha = 0.3;
    _previewLabel.userInteractionEnabled = NO;
    _previewLabel.alpha = 0.3;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)openCamera {
    if ([BLPhotoUtils getUseCount] + [BLPhotoUtils getWillUseCount] == self.maxSelectionNum) {
        [MBProgressHUD showTip:[NSString stringWithFormat:@"最多可以使用%ld张照片",(long)(self.maxSelectionNum - [BLPhotoUtils getUseCount])]];
    } else {
        UIImagePickerController * cameraController = [[UIImagePickerController alloc] init];
        cameraController.delegate = self;
        cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:cameraController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage * choosedImage = info[UIImagePickerControllerOriginalImage];
    
    [BLPhotoUtils setUseCount:[BLPhotoUtils getUseCount] + [BLPhotoUtils getWillUseCount] + 1];
    [BLPhotoUtils setWillUseCount:0];
    
    if ([self.delegate respondsToSelector:@selector(photoAssetPickerController:didFinishTakingPhoto:andPickingAssets:)]) {
        NSMutableArray *backAsset = [NSMutableArray array];
        for (int i = 0; i < _chooseIndexArray.count; i++) {
            [backAsset addObject:[_collectionDataSource objectAtIndex:(((NSIndexPath *)_chooseIndexArray[i]).row - (self.cameraEnable ? 1 : 0))]];
        }
        [self.delegate photoAssetPickerController:self didFinishTakingPhoto:choosedImage andPickingAssets:backAsset];
    }
    //后存防止改变数据源坐标
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImageWriteToSavedPhotosAlbum(choosedImage,nil,nil,nil);
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BLAssetPhotoCollectionViewCellDelegate

- (NSInteger)maxSeletionNum {
    return _maxSelectionNum;
}

- (void)putCellSelectedAtIndexPath:(NSIndexPath *)indexPath {
    [_chooseIndexArray addObject:indexPath];
    _choseCountLabel.text = [NSString stringWithFormat:@"%ld", (long) _chooseIndexArray.count];
    _choseCountLabel.hidden = NO;
    _finishLabel.alpha = 1;
    _finishLabel.userInteractionEnabled = YES;
    _previewLabel.alpha = 1;
    _previewLabel.userInteractionEnabled = YES;
    
    //数量够的情况下 置下相机和下面文字的透明度为50%
    if ([BLPhotoUtils getUseCount] + [BLPhotoUtils getWillUseCount] == self.maxSelectionNum && self.cameraEnable) {
        BLAssetCameraCollectionViewCell *cell =(BLAssetCameraCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.cameraImageView.alpha = 0.5;
        cell.cameraImageView.alpha = 0.5;
    }
    //add animation
    [_choseCountLabel.layer removeAllAnimations];
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    animation.springBounciness = 15;
    [_choseCountLabel pop_addAnimation:animation forKey:@"bounce"];
}

- (void)removeCellSelectedAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cameraEnable) {
        BLAssetCameraCollectionViewCell *cell =(BLAssetCameraCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.cameraImageView.alpha = 1;
        cell.cameraImageView.alpha = 1;
    }
    for (int i = 0 ;i<_chooseIndexArray.count ;i++) {
        if (((NSIndexPath*)[_chooseIndexArray objectAtIndex:i]).row == indexPath.row) {
            [_chooseIndexArray removeObjectAtIndex:i];
            _choseCountLabel.text = [NSString stringWithFormat:@"%ld", (long) _chooseIndexArray.count];
            
            if (_chooseIndexArray.count == 0) {
                _choseCountLabel.hidden = YES;
                _finishLabel.userInteractionEnabled = NO;
                _finishLabel.alpha = 0.3;
                _previewLabel.userInteractionEnabled = NO;
                _previewLabel.alpha = 0.3;
            }
            return;
        }
    }
}

#pragma mark - 查看大图与预览

- (void)bl_browseOriginalRepresentationPhotos:(BOOL)isPreview fromIndex:(NSInteger)fromIndex {
    _originalRepresentationPhotos = [NSMutableArray arrayWithCapacity:_collectionDataSource.count];
    _originalRepresentationPhotoIndexToPhotoIndex = [NSMutableDictionary dictionaryWithCapacity:_collectionDataSource.count];
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    // Sizing is very rough... more thought required in a real implementation
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    
    NSUInteger photoIndex = 0;
    if (isPreview) {
        for (NSIndexPath *indexPath in _chooseIndexArray) {
            id theAsset = _collectionDataSource[indexPath.item - (self.cameraEnable ? 1 : 0)];
            BOOL assetIsValid = NO;
            if ([theAsset isKindOfClass:[PHAsset class]]) {
                assetIsValid = YES;
                PHAsset *asset = (PHAsset *)theAsset;
                [_originalRepresentationPhotos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
            } else if ([theAsset isKindOfClass:[ALAsset class]]) {
                assetIsValid = YES;
                ALAsset *asset = (ALAsset *)theAsset;
                [_originalRepresentationPhotos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
            }
            if (assetIsValid) {
                _originalRepresentationPhotoIndexToPhotoIndex[@(photoIndex)] = @(indexPath.item);
                photoIndex++;
            }
        }
    } else {
        for (int i = 0; i < _collectionDataSource.count; i++) {
            id theAsset = _collectionDataSource[i];
            BOOL assetIsValid = NO;
            if ([theAsset isKindOfClass:[PHAsset class]]) {
                assetIsValid = YES;
                PHAsset *asset = (PHAsset *)theAsset;
                [_originalRepresentationPhotos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
            } else if ([theAsset isKindOfClass:[ALAsset class]]) {
                assetIsValid = YES;
                ALAsset *asset = (ALAsset *)theAsset;
                [_originalRepresentationPhotos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
            }
            if (assetIsValid) {
                _originalRepresentationPhotoIndexToPhotoIndex[@(photoIndex)] = @(i + (self.cameraEnable ? 1 : 0));
                photoIndex++;
            }
        }
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.zoomPhotosToFill = NO;
    browser.mode = MWPhotoBrowserModeSelectPhoto;
    [browser setCurrentPhotoIndex:fromIndex];
    
    id <MWPhoto> photo = [self photoBrowser:browser photoAtIndex:fromIndex];
    if (photo) {
//        提前加载图片，以保证界面效果
        [photo loadUnderlyingImageAndNotify];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:browser animated:YES];
        });
    } else {
        [self.navigationController pushViewController:browser animated:YES];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _originalRepresentationPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _originalRepresentationPhotos.count) {
        return _originalRepresentationPhotos[index];
    } else {
        return nil;
    }
}

- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _chooseIndexArray.count;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser shouldSelectPhotoAtIndex:(NSUInteger)index {
    if ([BLPhotoUtils getUseCount] + [BLPhotoUtils getWillUseCount] < self.maxSelectionNum) {
        return YES;
    } else {
        [MBProgressHUD showTip:[NSString stringWithFormat:@"最多可以使用%ld张照片",(long)(self.maxSelectionNum - [BLPhotoUtils getUseCount])]];
        return NO;
    }
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    NSInteger item = [_originalRepresentationPhotoIndexToPhotoIndex[@(index)] integerValue];
    NSArray *selectedIndex = [_chooseIndexArray valueForKey:@"item"];
    return [selectedIndex containsObject:@(item)];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    //此处转换item 是因为大图的数据源 既可能是全部 也可能是预览的
    NSInteger item = [_originalRepresentationPhotoIndexToPhotoIndex[@(index)] integerValue];
    BLAssetPhotoCollectionViewCell *cell = (BLAssetPhotoCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
    if (cell) {
        [cell changeSelectPhoto];
        [photoBrowser reloadData];
    }else {
        NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:item inSection:0];
        if (selected) {
            [BLPhotoUtils setWillUseCount:([BLPhotoUtils getWillUseCount] + 1 )];
            [self putCellSelectedAtIndexPath:targetIndexPath];
        }else {
            [BLPhotoUtils setWillUseCount:([BLPhotoUtils getWillUseCount] - 1 )];
            [self removeCellSelectedAtIndexPath:targetIndexPath];
        }
        [photoBrowser reloadData];
    }
}

- (void)photoBrowserDidTappedSelectFinishButton:(MWPhotoBrowser *)photoBrowser {
    [self finishChoosePhoto];
}

#pragma mark - Helpers

- (void)checkCameraPermissions:(void(^)(BOOL granted))callback
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        callback(YES);
        return;
    } else if (status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            callback(granted);
            return;
        }];
    } else {
        callback(NO);
    }
}

- (void)checkPhotosPermissions:(void(^)(BOOL granted))callback
{
    if (![PHPhotoLibrary class]) { // iOS 7 support
        callback(YES);
        return;
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        callback(YES);
        return;
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                callback(YES);
                return;
            }
            else {
                callback(NO);
                return;
            }
        }];
    }
    else {
        callback(NO);
    }
}

@end
