//
//  MWTitleView.m
//  Pods
//
//  Created by 柬斐 王 on 15/9/28.
//
//

#import "MWTitleView.h"
#import "MWCommon.h"

@interface MWTitleView () {
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}

@end

@implementation MWTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 44)]) {
        UILabel *titleLabel = [UILabel new];
        titleLabel.textColor = UIColorFromRGB(0x252525);
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UILabel *subtitleLabel = [UILabel new];
        subtitleLabel.textColor = UIColorFromRGB(0x252525);
        subtitleLabel.font = [UIFont systemFontOfSize:10];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:subtitleLabel];
        _subtitleLabel = subtitleLabel;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize titleSize = [self sizeWithLabel:_titleLabel];
    CGSize subtitleSize = [self sizeWithLabel:_subtitleLabel];
    return CGSizeMake(MAX(titleSize.width, subtitleSize.width), titleSize.height + 3 + subtitleSize.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize titleSize = [self sizeWithLabel:_titleLabel];
    CGSize subtitleSize = [self sizeWithLabel:_subtitleLabel];
    
    _titleLabel.frame = CGRectMake((self.bounds.size.width - titleSize.width) / 2, 0, titleSize.width, titleSize.height);
    _subtitleLabel.frame = CGRectMake((self.bounds.size.width - subtitleSize.width) / 2, titleSize.height + 3, subtitleSize.width, subtitleSize.height);
}

#pragma mark - Utilities

- (CGSize)sizeWithLabel:(UILabel *)label {
    return [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
}

#pragma mark - Properties

- (NSString *)title {
    return _titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)subtitle {
    return _subtitleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitleLabel.text = subtitle;
    [self setNeedsLayout];
}

@end
