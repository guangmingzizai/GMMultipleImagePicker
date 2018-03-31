//
//  MWInbilinActionBar.m
//  Pods
//
//  Created by 柬斐 王 on 15/9/29.
//
//

#import "MWInbilinActionBar.h"
#import "MWPhotoBrowser.h"
#import "MWCommon.h"
#import "UIImage+MWPhotoBrowser.h"

@interface MWInbilinActionBar ()

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, weak) MWPhotoBrowser *photoBrowser;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *greetButton;
@property (nonatomic, strong) UIView *seperatorLine;

@end

@implementation MWInbilinActionBar

- (instancetype)initWithFrame:(CGRect)frame photoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (self = [super initWithFrame:frame]) {
        self.photoBrowser = photoBrowser;
       
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [self addSubview:self.likeButton];
        [self addSubview:self.commentButton];
        [self addSubview:self.greetButton];
        [self addSubview:self.seperatorLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIFont *font = [UIFont systemFontOfSize:10];
    CGSize iconSize = CGSizeMake(14, 14);
    CGFloat standardTitleWidth = 32;
    
    NSString *commentButtonTitle = [self.commentButton titleForState:UIControlStateNormal];
    CGSize commentButtonTitleSize = [commentButtonTitle sizeWithAttributes:@{NSFontAttributeName: font}];
    CGSize commentButtonSize = CGSizeMake(iconSize.width+6+commentButtonTitleSize.width, self.bounds.size.height);
    self.commentButton.frame = CGRectMake(self.bounds.size.width - commentButtonSize.width - (standardTitleWidth - commentButtonTitleSize.width), 0, commentButtonSize.width, commentButtonSize.height);
    
    NSString *likeButtonTitle = [self.likeButton titleForState:UIControlStateNormal];
    CGSize likeButtonTitleSize = [likeButtonTitle sizeWithAttributes:@{NSFontAttributeName: font}];
    CGSize likeButtonSize = CGSizeMake(iconSize.width+6+likeButtonTitleSize.width, self.bounds.size.height);
    self.likeButton.frame = CGRectMake(CGRectGetMinX(self.commentButton.frame) - likeButtonSize.width - (standardTitleWidth - likeButtonTitleSize.width), 0, likeButtonSize.width, likeButtonSize.height);
    
    if (!self.greetButton.hidden) {
        NSString *greetButtonTitle = [self.greetButton titleForState:UIControlStateNormal];
        CGSize greetButtonTitleSize = [greetButtonTitle sizeWithAttributes:@{NSFontAttributeName: font}];
        CGSize greetButtonSize = CGSizeMake(iconSize.width+3+greetButtonTitleSize.width, self.bounds.size.height);
        self.greetButton.frame = CGRectMake(19, 0, greetButtonSize.width, greetButtonSize.height);
    }
    
    self.seperatorLine.frame = CGRectMake(12, 0, self.bounds.size.width - 12 * 2, 0.5);
}

- (void)updateData:(NSUInteger)index {
    self.index = index;
    
    NSString *likeButtonTitle = @"点赞";
    BOOL liked = NO;
    
    NSString *commentButtonTitle = @"评论";
    BOOL commented = NO;
    
    if ([self.photoBrowser.delegate respondsToSelector:@selector(photoBrowser:praiseNumAtIndex:isPraise:)]) {
        NSUInteger likeNum = [self.photoBrowser.delegate photoBrowser:self.photoBrowser praiseNumAtIndex:index isPraise:&liked];
        if (likeNum > 0) {
            likeButtonTitle = [NSString stringWithFormat:@"%lu", (unsigned long)likeNum];
        }
        [self.likeButton setTitle:likeButtonTitle forState:UIControlStateNormal];
        self.likeButton.selected = liked;
    }
    if ([self.photoBrowser.delegate respondsToSelector:@selector(photoBrowser:commentNumAtIndex:isComment:)]) {
        NSUInteger commentNum = [self.photoBrowser.delegate photoBrowser:self.photoBrowser commentNumAtIndex:index isComment:&commented];
        if (commentNum > 0) {
            commentButtonTitle = [NSString stringWithFormat:@"%lu", (unsigned long)commentNum];
        }
        [self.commentButton setTitle:commentButtonTitle forState:UIControlStateNormal];
        self.commentButton.selected = commented;
    }
    
    if ([self.photoBrowser.delegate respondsToSelector:@selector(photoBrowser:shouldShowGreetActionButtonAtIndex:)] &&
        [self.photoBrowser.delegate photoBrowser:self.photoBrowser shouldShowGreetActionButtonAtIndex:index]) {
        self.greetButton.hidden = NO;
    } else {
        self.greetButton.hidden = YES;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Buttons

- (UIButton *)likeButton {
    if (!_likeButton) {
        UIButton *button = [UIButton new];
        [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xffc200) forState:UIControlStateSelected];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/LikeActionIcon@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/LikedActionIcon@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        [button addTarget:self action:@selector(didTapLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        
        _likeButton = button;
    }
    return _likeButton;
}

- (UIButton *)commentButton {
    if (!_commentButton) {
        UIButton *button = [UIButton new];
        [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xffc200) forState:UIControlStateSelected];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/CommentActionIcon@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/CommentedActionIcon@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        [button addTarget:self action:@selector(didTapCommentButton) forControlEvents:UIControlEventTouchUpInside];
        
        _commentButton = button;
    }
    return _commentButton;
}

- (UIButton *)greetButton {
    if (!_greetButton) {
        UIButton *button = [UIButton new];
        [button setTitle:@"打招呼" forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xffc200) forState:UIControlStateSelected];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/GreetActionIcon@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/GreetActionIcon@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        [button addTarget:self action:@selector(didTapGreetButton) forControlEvents:UIControlEventTouchUpInside];
        
        _greetButton = button;
    }
    return _greetButton;
}

- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        UIView *view = [UIView new];
        view.backgroundColor = UIColorFromRGBA(0xffffff, 0.3);
        
        _seperatorLine = view;
    }
    return _seperatorLine;
}

#pragma mark - Actions

- (void)didTapLikeButton:(UIButton *)sender {
    if ([self.photoBrowser.delegate respondsToSelector:@selector(photoBrowser:didPraisePhotoAtIndex:praiseButton:)]) {
        [self.photoBrowser.delegate photoBrowser:self.photoBrowser didPraisePhotoAtIndex:self.index praiseButton:sender];
    }
}

- (void)didTapCommentButton {
    if ([self.photoBrowser.delegate respondsToSelector:@selector(photoBrowser:didCommentPhotoAtIndex:)]) {
        [self.photoBrowser.delegate photoBrowser:self.photoBrowser didCommentPhotoAtIndex:self.index];
    }
}

- (void)didTapGreetButton {
    if ([self.photoBrowser.delegate respondsToSelector:@selector(photoBrowser:didTappedGreetButtonAtIndex:)]) {
        [self.photoBrowser.delegate photoBrowser:self.photoBrowser didTappedGreetButtonAtIndex:self.index];
    }
}

@end
