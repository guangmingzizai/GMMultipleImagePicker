//
//  MWInbilinProgressView.m
//  Pods
//
//  Created by 柬斐 王 on 15/10/4.
//
//

#import "MWInbilinProgressView.h"
#import "MWCommon.h"

@interface MWInbilinProgressView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *leftProgressView;
@property (nonatomic, strong) UIView *topProgressView;
@property (nonatomic, strong) UIView *rightProgressView;
@property (nonatomic, strong) UIView *bottomProgressView;

@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation MWInbilinProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.progress = 0.0;
        self.clipsToBounds = YES;
        
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [self addSubview:_imageView];
        
        _maskView = [UIView new];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self addSubview:_maskView];
        
        _leftProgressView = [UIView new];
        _topProgressView = [UIView new];
        _rightProgressView = [UIView new];
        _bottomProgressView = [UIView new];
        
        _leftProgressView.backgroundColor = _topProgressView.backgroundColor = _rightProgressView.backgroundColor = _bottomProgressView.backgroundColor = UIColorFromRGB(0xffc200);
        _leftProgressView.alpha = _topProgressView.alpha = _rightProgressView.alpha = _bottomProgressView.alpha = 0.25;
        
        [self addSubview:_leftProgressView];
        [self addSubview:_topProgressView];
        [self addSubview:_rightProgressView];
        [self addSubview:_bottomProgressView];
        
        _progressLabel = [UILabel new];
        _progressLabel.font = [UIFont systemFontOfSize:16];
        _progressLabel.textColor = UIColorFromRGB(0xffc200);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_progressLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    _maskView.frame = self.bounds;
    
    CGFloat horizontalProgressLength = (self.bounds.size.width - 2) * _progress;
    CGFloat verticalProgressLength = (self.bounds.size.height - 2) * _progress;
    _leftProgressView.frame = CGRectMake(0, self.bounds.size.height - verticalProgressLength, 2, verticalProgressLength);
    _topProgressView.frame = CGRectMake(0, 0, horizontalProgressLength, 2);
    _rightProgressView.frame = CGRectMake(self.bounds.size.width - 2, 0, 2, verticalProgressLength);
    _bottomProgressView.frame = CGRectMake(self.bounds.size.width - horizontalProgressLength, self.bounds.size.height - 2, horizontalProgressLength, 2);
    
    _progressLabel.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.image) {
        CGSize imageSize = self.image.size;
        imageSize.width /= 2;
        imageSize.height /= 2;
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenBound.size.width;
        CGFloat screenHeight = screenBound.size.height;
        
        // Calculate Min
        CGFloat xScale = imageSize.width / screenWidth;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = imageSize.height / screenHeight;  // the scale needed to perfectly fit the image height-wise
        CGFloat maxScale = MAX(xScale, yScale);
        if (xScale > 1 || yScale > 1) {
            CGFloat finalWidth = imageSize.width / maxScale;
            CGFloat finalHeight = imageSize.height / maxScale;
            return CGSizeMake(finalWidth, finalHeight);
        } else {
            return imageSize;
        }
    } else {
        return CGSizeMake(44, 44);
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_progress * 100)];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

- (UIImage *)image {
    return self.imageView.image;
}

@end
