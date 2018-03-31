//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

typedef NS_ENUM(NSUInteger, MWPhotoBrowserMode) {
    MWPhotoBrowserModeNormal,
    MWPhotoBrowserModePurePhoto,
    MWPhotoBrowserModeSelectPhoto,
    MWPhotoBrowserModeSelectSinglePhoto,
    MWPhotoBrowserModeSelectedPhoto,
};

@class MWPhotoBrowser;

@protocol MWPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (UIView <MWCaptionView> *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser shouldSelectPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;
- (void)photoBrowserWillDismiss:(MWPhotoBrowser *)photoBrowser;
- (void)photoBrowserDidDismiss:(MWPhotoBrowser *)photoBrowser;

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser scaleImageAtIndex:(NSUInteger)index;
- (UIImageView *)photoBrowser:(MWPhotoBrowser *)photoBrowser scaleAnimationImageViewAtIndex:(NSUInteger)index;
- (CGRect)photoBrowser:(MWPhotoBrowser *)photoBrowser scaleAnimationImageViewFrameAtIndex:(NSUInteger)index;
- (Class)titleViewClassInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;

- (BOOL)shouldShowActionBarInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser shouldShowGreetActionButtonAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didTappedGreetButtonAtIndex:(NSUInteger)index;
- (NSUInteger)photoBrowser:(MWPhotoBrowser *)photoBrowser praiseNumAtIndex:(NSUInteger)index isPraise:(BOOL*)isPraise;
- (NSUInteger)photoBrowser:(MWPhotoBrowser *)photoBrowser commentNumAtIndex:(NSUInteger)index isComment:(BOOL*)isComment;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didPraisePhotoAtIndex:(NSInteger)index praiseButton:(UIButton *)praiseButton;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser publishDateStringAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDeletePhotoAtIndex:(NSInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didCommentPhotoAtIndex:(NSInteger)index;
- (NSURL *)photoBrowser:(MWPhotoBrowser *)photoBrowser profileImgUrlAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser indexInfoAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (void)photoBrowserDidTappedSelectFinishButton:(MWPhotoBrowser *)photoBrowser;

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didTappedDeleteButtonAtIndex:(NSUInteger)index;

- (void)photoBrowserDidTappedDoneButton:(MWPhotoBrowser *)photoBrowser;

@end

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet id<MWPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;
@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic) MWPhotoBrowserMode mode;

// Customise image selection icons as they are the only icons with a colour tint
// Icon should be located in the app's main bundle
@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;

// animation time (default .28)
@property (nonatomic) float animationDuration;
@property (nonatomic) BOOL usePopAnimation;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
