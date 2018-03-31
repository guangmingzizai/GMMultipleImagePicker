//
//  BLAssetCameraCollectionViewCell.m
//  BiLin
//
//  Created by devduwan on 15/9/28.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLAssetCameraCollectionViewCell.h"
#import "Constants.h"
#import <Masonry/Masonry.h>
#import "UIImage+MultipleImagePicker.h"

@implementation BLAssetCameraCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.borderColor = UIColorFromRGB(0xececec).CGColor;
        self.layer.borderWidth = 0.5;
       
        self.contentView.backgroundColor = UIColorFromRGB(0xf8f8f8);
       
        _coverView = [[UIView alloc]init];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.1;
        _coverView.hidden = YES;
        [self addSubview:_coverView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.mas_equalTo(0);
            }];
        });
        
        NSString *cameraStr = NSLocalizedString(@"拍摄照片", nil);
        CGSize size = [cameraStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        size.width += 2;
        _cameraLabel = [[UILabel alloc]init];
        [self addSubview:_cameraLabel];
        _cameraLabel.textColor = UIColorFromRGB(0xffcb00);
        _cameraLabel.textAlignment = NSTextAlignmentCenter;
        _cameraLabel.font = [UIFont systemFontOfSize:12];
        _cameraLabel.text = cameraStr;
        //collectionViewCell先绘制
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.mas_centerX);
                make.size.mas_equalTo(size);
                make.bottom.mas_equalTo(-(self.frame.size.height/2 - (45+7+size.height)/2));
            }];
        });
        
        _cameraImageView = [[UIImageView alloc]initWithImage:[UIImage _imageForName:@"status_camera" inBundle:[NSBundle bundleForClass:[self class]]]];
        [self addSubview:_cameraImageView];
        //collectionViewCell先绘制
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_cameraImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.mas_centerX);
                make.size.mas_equalTo(CGSizeMake(45, 45));
                make.top.mas_equalTo(self.frame.size.height/2 - (45+7+size.height)/2);
            }];
        });
    }
    return self;
}

@end
