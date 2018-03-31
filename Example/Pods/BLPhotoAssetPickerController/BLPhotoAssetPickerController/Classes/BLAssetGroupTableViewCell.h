//
//  BLAssetGroupTableViewCell.h
//  BiLin
//
//  Created by devduwan on 15/9/28.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLAssetGroupTableViewCell : UITableViewCell

@property(nonatomic, strong)UIImageView *iconImageView;
@property(nonatomic, strong)UILabel *groupLabel;
@property(nonatomic, strong)UILabel *groupPicCountLabel;
@property(nonatomic, assign)long long cellBgColor;


- (void)changeGroupLabelContrainsByString:(NSString *)groupName;

- (void)bind:(NSObject *)groups atIndex:(NSIndexPath *)indexPath;


@end
