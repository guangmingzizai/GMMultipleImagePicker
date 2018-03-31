//
//  BLAssetSwitch.m
//  BiLin
//
//  Created by devduwan on 15/9/24.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLAssetSwitch.h"
#import <Masonry/Masonry.h>
#import "UIImage+MultipleImagePicker.h"

@implementation BLAssetSwitch {
    UIView *_titleView;
    UIImageView *_titleImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        NSString *title = NSLocalizedString(@"相机胶卷", nil);
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
        CGRect titleRect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        float width = titleRect.size.width + 2;
        CGSize labelSize = CGSizeMake(width, 44);

        _titleView = [[UIView alloc]init];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.userInteractionEnabled = YES;
        UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeSelectStatus)];
        [_titleView addGestureRecognizer:recognizer];
        [self addSubview:_titleView];
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(width + 3 + 14, 44));
            make.center.mas_equalTo(self);
        }];

        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = NSLocalizedString(@"相机胶卷", nil);
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        [_titleView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(_titleView.mas_centerY);
            make.size.mas_equalTo(labelSize);
        }];

        _titleImageView = [[UIImageView alloc]initWithImage:[UIImage _imageForName:@"status_pic_down" inBundle:[NSBundle bundleForClass:[self class]]]];
        [_titleView addSubview:_titleImageView];
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_titleLabel.mas_right).offset(3);
            make.right.mas_equalTo(0);
            make.centerY.mas_equalTo(_titleView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(14, 14));
        }];
        
        self.selectedOption = BLAssetSwitchPhotoPreviewAll;
    }
    return self;
}

- (void)changeSelectStatus {
    switch (self.selectedOption) {
        case BLAssetSwitchPhotoPreviewAll:
            {
                CABasicAnimation *rationUp = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                rationUp.fromValue = [NSNumber numberWithFloat:0];
                rationUp.toValue = [NSNumber numberWithFloat:-M_PI+0.0001f];
                rationUp.duration = 0.2;
                rationUp.repeatCount = 0;
                rationUp.fillMode = kCAFillModeForwards;
                rationUp.removedOnCompletion = NO;
                [_titleImageView.layer addAnimation:rationUp forKey:@"animateTransform"];
                
                self.selectedOption = BLAssetSwitchPhotos;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            break;
        case BLAssetSwitchPhotos:
            {
                CABasicAnimation *rationDown = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                rationDown.duration = 0.2;
                rationDown.fromValue = [NSNumber numberWithFloat:-M_PI+0.0001f];
                rationDown.toValue = [NSNumber numberWithFloat:0];
                rationDown.repeatCount = 0;
                rationDown.removedOnCompletion = NO;
                rationDown.fillMode = kCAFillModeForwards;
                [_titleImageView.layer addAnimation:rationDown forKey:@"animateTransform"];
                
                self.selectedOption = BLAssetSwitchPhotoPreviewAll;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            break;
        default:
            break;
    }
}

- (void)updateConstraintsWithString:(NSString *)str {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]
                                 ,NSForegroundColorAttributeName : [UIColor blackColor]};
    CGRect titleRect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:attributes
                                              context:nil];
    [_titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(titleRect.size.width + 2 + 3 + 14, 44));
        make.center.mas_equalTo(self);
    }];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(_titleView.mas_centerY);
        //boundingRectWithSize 算的不太准 
        make.size.mas_equalTo(CGSizeMake(titleRect.size.width + 2, 44));
    }];
    
    [_titleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLabel.mas_right).offset(3);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(_titleView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
}

- (CGSize)intrinsicContentSize {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]
                                 ,NSForegroundColorAttributeName : [UIColor blackColor]};
    CGRect titleRect = [_titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    return CGSizeMake(titleRect.size.width + 2 + 3 + 14 + 2 * 8, 44);
}

@end
