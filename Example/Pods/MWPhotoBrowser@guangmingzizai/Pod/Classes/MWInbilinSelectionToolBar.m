//
//  MWInbilinSelectionToolBar.m
//  Pods
//
//  Created by 柬斐 王 on 15/10/4.
//
//

#import "MWInbilinSelectionToolBar.h"
#import "MWCommon.h"
#import <pop/POPSpringAnimation.h>
#import "UIButton+ExtendedHit.h"

@interface MWInbilinSelectionToolBar ()

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *finishButton;

@end

@implementation MWInbilinSelectionToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        [self addSubview:self.countLabel];
        [self addSubview:self.finishButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSString *finishButtonTitle = [self.finishButton titleForState:UIControlStateNormal];
    CGSize finishButtonSize = [finishButtonTitle sizeWithAttributes:@{NSFontAttributeName: self.finishButton.titleLabel.font}];
    self.finishButton.frame = CGRectMake(self.bounds.size.width - finishButtonSize.width - 12, 0, finishButtonSize.width, self.bounds.size.height);
    self.countLabel.frame = CGRectMake(self.bounds.size.width - finishButtonSize.width - 12 - 7 - 22, (self.bounds.size.height - 22) / 2, 22, 22);
    self.finishButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -(2 * 7 + 12), 0, -12);
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        UILabel *label = [UILabel new];
        label.backgroundColor = UIColorFromRGB(0xffc200);
        label.layer.cornerRadius = 11;
        label.layer.masksToBounds = YES;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        
        _countLabel = label;
    }
    return _countLabel;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        UIButton *button = [UIButton new];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xffc200) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        
        _finishButton = button;
    }
    return _finishButton;
}

- (void)setSelectionCount:(NSUInteger)selectionCount {
    NSUInteger originalCount = _countLabel.text.integerValue;
    
    _countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)selectionCount];
    _countLabel.hidden = (selectionCount == 0);
    
    if (!_countLabel.hidden && originalCount != selectionCount) {
        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
        animation.springBounciness = 15;
        [_countLabel pop_addAnimation:animation forKey:@"bounce"];
    }
}

- (void)addFinishButtonTarget:(id)target action:(SEL)action {
    [self.finishButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
