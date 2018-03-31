//
//  MWInbilinNavigationBar.m
//  Pods
//
//  Created by 柬斐 王 on 15/9/29.
//
//

#import "MWInbilinNavigationBar.h"
#import "MWCommon.h"

@interface MWInbilinNavigationBar ()

@property (nonatomic, strong) CAGradientLayer *gradientBackgroundView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MWInbilinNavigationBar

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;
        UIColor *startColor = UIColorFromRGBA(0x000000, 0.5);
        UIColor *endColor = UIColorFromRGBA(0x000000, 0.0);
        layer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(0, 1);
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGB(0xffffff);
        label.font = [UIFont systemFontOfSize:12];
        
        _titleLabel = label;
    }
    return _titleLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(12, 20, self.bounds.size.width-2*12, self.titleLabel.font.lineHeight);
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
