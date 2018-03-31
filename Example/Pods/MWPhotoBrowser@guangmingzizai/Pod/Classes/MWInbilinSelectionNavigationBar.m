//
//  MWInbilinSelectionNavigationBar.m
//  Pods
//
//  Created by 柬斐 王 on 15/9/30.
//
//

#import "MWInbilinSelectionNavigationBar.h"
#import "UIImage+MWPhotoBrowser.h"

@interface MWInbilinSelectionNavigationBar ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation MWInbilinSelectionNavigationBar

//UIBarButtonItemInbilinBackArrow
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self addSubview:self.backButton];
        [self addSubview:self.selectButton];
    }
    return self;
}

- (UIButton *)backButton {
    if (!_backButton) {
        UIImage *image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/UIBarButtonItemInbilinBackArrow@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
        
        CGRect frame = CGRectMake(12, 21, 22, 22);
        frame = CGRectInset(frame, -11, -11);
        
        UIButton *button = [UIButton new];
        [button setImage:image forState:UIControlStateNormal];
        button.frame = frame;
        
        _backButton = button;
    }
    return _backButton;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        UIImage *image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/UIBarButtonItemInbilinNonSelected@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
        UIImage *selectedImage = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/UIBarButtonItemInbilinSelected@2x" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
        
        CGRect frame = CGRectMake(self.bounds.size.width - 12 - 22, 21, 22, 22);
        frame = CGRectInset(frame, -11, -11);
        
        UIButton *button = [UIButton new];
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:selectedImage forState:UIControlStateSelected];
        button.frame = frame;
        
        _selectButton = button;
    }
    return _selectButton;
}

- (void)addBackButtonTarget:(id)target selector:(SEL)selector {
    [self.backButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)addSelectButtonTarget:(id)target selector:(SEL)selector {
    [self.selectButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateSelectButton:(BOOL)isSelected {
    self.selectButton.selected = isSelected;
}

@end
