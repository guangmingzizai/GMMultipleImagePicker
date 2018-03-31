//
//  BLAssetSwitch.h
//  BiLin
//
//  Created by devduwan on 15/9/24.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , BLAssetSwitchOption) {
    BLAssetSwitchPhotoPreviewAll,
    BLAssetSwitchPhotos
};
@interface BLAssetSwitch : UIControl

@property(nonatomic, assign) BLAssetSwitchOption selectedOption;

@property(nonatomic, strong) UILabel *titleLabel;

- (void)changeSelectStatus;

- (void)updateConstraintsWithString:(NSString *)str;

@end
