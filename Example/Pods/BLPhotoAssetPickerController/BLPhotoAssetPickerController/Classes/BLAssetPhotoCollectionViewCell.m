//
//  BLAssetPhotoCollectionViewCell.m
//  BiLin
//
//  Created by devduwan on 15/9/28.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLAssetPhotoCollectionViewCell.h"
#import "BLPhotoDataCenter.h"
#import "MBProgressHUD+Add.h"
#import "BLPhotoUtils.h"
#import <pop/POPSpringAnimation.h>
#import <Masonry/Masonry.h>
#import "UIImage+MultipleImagePicker.h"

#define kThumbnailLength    (UI_SCREEN_WIDTH/3 -36/3)

@implementation BLAssetPhotoCollectionViewCell {
    NSMutableArray *_photoAssets;
    
    MBProgressHUD *_outofChooseHud;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _picImageView = [[UIImageView alloc]init];
        [self addSubview:_picImageView];
        
        _picImageView.backgroundColor = [UIColor clearColor];
        
        _chooseStatus = BLPhotoChooseUnSelected;
        
        _chooseView = [[UIView alloc]init];
        _chooseView.backgroundColor = [UIColor clearColor];
        [self addSubview:_chooseView];
        _chooseView.userInteractionEnabled = YES;
        [_chooseView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSelectPhoto)]];
        
        _chooseImageView= [[UIImageView alloc]initWithImage:[UIImage _imageForName:@"status_pic_unselect" inBundle:[NSBundle bundleForClass:[self class]]]];
        _chooseImageView.backgroundColor = [UIColor clearColor];
        _chooseImageView.userInteractionEnabled = YES;
        [_chooseImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeSelectPhoto)]];
        [_chooseView addSubview:_chooseImageView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.mas_equalTo(0);
            }];
            
            [_chooseView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.right.mas_equalTo(5);
                make.size.mas_equalTo(CGSizeMake(40,35));
            }];
            [_chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-8);
                make.top.mas_equalTo(3);
                make.size.mas_equalTo(CGSizeMake(22, 22));
            }];
        });
    }
    return self;
}

- (void)bind:(NSObject *)dataSource {
    [BLPhotoDataCenter bindPhotoCellData:dataSource withBlock:^(UIImage *thumbnailImage) {
        _picImageView.image = thumbnailImage;
    }];
}

- (void)changeSelectPhoto {
    switch (_chooseStatus) {
        case BLPhotoChooseSelectd:
            [BLPhotoUtils setWillUseCount:([BLPhotoUtils getWillUseCount] - 1)];
            _chooseStatus = BLPhotoChooseUnSelected;
            [_chooseImageView.layer removeAllAnimations];
            _chooseImageView.image = [UIImage _imageForName:@"status_pic_unselect" inBundle:[NSBundle bundleForClass:[self class]]];
            if ([self.collectionViewDelegate respondsToSelector:@selector(removeCellSelectedAtIndexPath:)]) {
                [self.collectionViewDelegate removeCellSelectedAtIndexPath:self.indexPath];
            }
            break;
        case BLPhotoChooseUnSelected:
            if ([BLPhotoUtils getWillUseCount] + [BLPhotoUtils getUseCount] == [self _maxSelectionNum]) {
                _outofChooseHud = [MBProgressHUD showHUDInKeyWindowWithImage:nil text:[NSString stringWithFormat:@"最多可以选择%ld张照片",(long)([self _maxSelectionNum] - [BLPhotoUtils getUseCount])] duration:1];
                return;
            }
            [BLPhotoUtils setWillUseCount:([BLPhotoUtils getWillUseCount] + 1)];
            _chooseStatus = BLPhotoChooseSelectd;
            _chooseImageView.image = [UIImage _imageForName:@"status_pic_selected" inBundle:[NSBundle bundleForClass:[self class]]];
            //add animation
            [_chooseImageView.layer removeAllAnimations];
            POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.75, 0.75)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
            animation.springBounciness = 20;
            [_chooseImageView pop_addAnimation:animation forKey:@"bounce"];
            
            if ([self.collectionViewDelegate respondsToSelector:@selector(putCellSelectedAtIndexPath:)]) {
                [self.collectionViewDelegate putCellSelectedAtIndexPath:self.indexPath];
            }
            break;
    }
}

- (NSInteger)_maxSelectionNum {
    if ([self.collectionViewDelegate respondsToSelector:@selector(maxSeletionNum)]) {
        return [self.collectionViewDelegate maxSeletionNum];
    } else {
        return 9;
    }
}

@end
