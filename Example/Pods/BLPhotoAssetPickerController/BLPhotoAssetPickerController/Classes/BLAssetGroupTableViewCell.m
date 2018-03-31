//
//  BLAssetGroupTableViewCell.m
//  BiLin
//
//  Created by devduwan on 15/9/28.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLAssetGroupTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "BLPhotoDataCenter.h"
#import <Masonry/Masonry.h>
#import "UIImage+MultipleImagePicker.h"
#import "Constants.h"

#define kThumbnailLength    (UI_SCREEN_WIDTH/3 -36/3)

@implementation BLAssetGroupTableViewCell {

}

//一行大标准 高度为65

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cellBgColor = 0xfbfbfb;
        self.contentView.backgroundColor = UIColorFromRGB(_cellBgColor);
        
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.backgroundColor = [UIColor redColor];
        [self addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(45, 45));
            make.left.mas_equalTo(12);
        }];
        
        _groupLabel = [[UILabel alloc]init];
        _groupLabel.backgroundColor = [UIColor clearColor];
        _groupLabel.text = NSLocalizedString(@"相机胶卷", nil);
        _groupLabel.textColor = [UIColor blackColor];
        _groupLabel.font = [UIFont systemFontOfSize:16];
        CGSize defaultSize = [_groupLabel.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
        [self addSubview:_groupLabel];
        [_groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_iconImageView.mas_right).with.offset(10);
            make.size.mas_equalTo(defaultSize);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        _groupPicCountLabel = [[UILabel alloc]init];
        _groupPicCountLabel.text = @"0";
        _groupPicCountLabel.textColor = UIColorFromRGB(0x252525);
        _groupPicCountLabel.font = [UIFont systemFontOfSize:10];
        _groupPicCountLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_groupPicCountLabel];
        [_groupPicCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_groupLabel.mas_right).with.offset(4);
            make.size.mas_equalTo(CGSizeMake(80, defaultSize.height));
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    return self;
}

- (void)changeGroupLabelContrainsByString:(NSString *)groupName {
    CGSize size = [groupName sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    [_groupLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconImageView.mas_right).with.offset(10);
        make.centerY.mas_equalTo(self.mas_centerY);
        //QQ这种特殊字符
        make.size.mas_equalTo(CGSizeMake(size.width+2, size.height+2));
    }];
    [_groupLabel setNeedsDisplay];
}

#pragma mark - Bind Data

- (void)bind:(PHAssetCollection *)groups atIndex:(NSIndexPath *)indexPath {
    if (indexPath.row%2 == 0) {
        self.cellBgColor = 0xffffff;
    } else {
        self.cellBgColor = 0xfbfbfb;
    }
    
    self.selectedBackgroundView.backgroundColor = UIColorFromRGBA(0x000000, 0.1);
    
    self.contentView.backgroundColor = UIColorFromRGB(_cellBgColor);
    
    __weak __typeof(self) weakSelf = self;
    [BLPhotoDataCenter bindGroupcellData:groups withBlock:^(NSString *title, NSString *count, UIImage *posterImage) {
        weakSelf.iconImageView.image = posterImage;
        weakSelf.groupLabel.text = title;
        weakSelf.groupPicCountLabel.text = count;
        [weakSelf changeGroupLabelContrainsByString:weakSelf.groupLabel.text];
    }];
    
    return;
}

@end
