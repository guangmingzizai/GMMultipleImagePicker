//
//  ZoomingScrollView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <DACircularProgress/DACircularProgressView.h>
#import "MWCommon.h"
#import "MWZoomingScrollView.h"
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"
#import "MWPhotoBrowserPrivate.h"
#import "UIImage+MWPhotoBrowser.h"
#import "MWInbilinProgressView.h"

// Private methods and properties
@interface MWZoomingScrollView () {
    
    MWPhotoBrowser __weak *_photoBrowser;
	MWTapDetectingView *_tapView; // for background taps
	MWTapDetectingImageView *_photoImageView;
	DACircularProgressView *_loadingIndicator;
    MWInbilinProgressView *_inbilinProgressView;
    UIImageView *_loadingError;
    UIView __weak *_resizableImageView;
}

@end

@implementation MWZoomingScrollView

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser {
    if ((self = [super init])) {
        
        // Setup
        _index = NSUIntegerMax;
        _photoBrowser = browser;
        
		// Tap view for background
		_tapView = [[MWTapDetectingView alloc] initWithFrame:self.bounds];
		_tapView.tapDelegate = self;
		_tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapView.backgroundColor = [UIColor blackColor];
		[self addSubview:_tapView];
		
		// Image view
		_photoImageView = [[MWTapDetectingImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.tapDelegate = self;
		_photoImageView.contentMode = UIViewContentModeCenter;
		_photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:_photoImageView];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGestureRecognizer.minimumPressDuration = 0.5;
        [_photoImageView addGestureRecognizer:longPressGestureRecognizer];
		
		// Loading indicator
		_loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
        _loadingIndicator.userInteractionEnabled = NO;
        _loadingIndicator.thicknessRatio = 0.1;
        _loadingIndicator.roundedCorners = NO;
        _loadingIndicator.hidden = YES;
		_loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_loadingIndicator];
        
        _inbilinProgressView = [MWInbilinProgressView new];
        _inbilinProgressView.hidden = YES;
        [self addSubview:_inbilinProgressView];

        // Listen progress notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setProgressFromNotification:)
                                                     name:MWPHOTO_PROGRESS_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setLowQualityImageFromNotification:)
                                                     name:MWPHOTO_LOW_QUALITY_IMAGE_LOADED_NOTIFICATION
                                                   object:nil];
		// Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [self hideImageFailure];
    self.photo = nil;
    self.captionView = nil;
    self.selectedButton = nil;
    self.playButton = nil;
    _photoImageView.hidden = NO;
    _photoImageView.image = nil;
    _index = NSUIntegerMax;
    [self hideLoadingIndicator];
    [_resizableImageView.layer removeAllAnimations];
}

- (BOOL)displayingVideo {
    return [_photo respondsToSelector:@selector(isVideo)] && _photo.isVideo;
}

- (void)setImageHidden:(BOOL)hidden {
    _photoImageView.hidden = hidden;
}

#pragma mark - Image

- (void)setPhoto:(id<MWPhoto>)photo {
    // Cancel any loading on old photo
    if (_photo && photo == nil) {
        if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photo cancelAnyLoading];
        }
    }
    _photo = photo;
    UIImage *img = [_photoBrowser imageForPhoto:_photo];
    if (img) {
        [self displayImage];
    } else {
        // Will be loading so show loading
        [self showLoadingIndicator];
    }
}

// Get and display image
- (void)displayImage {
	if (_photo && _photoImageView.image == nil) {
		
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
		
		// Get image from browser as it handles ordering of fetching
		UIImage *img = [_photoBrowser imageForPhoto:_photo];
		if (img) {
			
			// Hide indicator
            
            void (^displayImageBlock)(void) = ^{
                [self hideLoadingIndicator];
                
                // Set image
                _photoImageView.image = img;
                _photoImageView.hidden = NO;
                
                // Setup photo frame
                CGRect photoImageViewFrame;
                photoImageViewFrame.origin = CGPointZero;
                photoImageViewFrame.size = img.size;
                _photoImageView.frame = photoImageViewFrame;
                self.contentSize = photoImageViewFrame.size;
                
                // Set zoom to minimum zoom
                [self setMaxMinZoomScalesForCurrentBounds];
                [self setNeedsLayout];
            };
            
            if (_inbilinProgressView && !_inbilinProgressView.hidden && _inbilinProgressView.image && ABS(_inbilinProgressView.progress - 1.0) < 0.001) {
                UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:img];
                resizableImageView.frame = _inbilinProgressView.frame;
                resizableImageView.clipsToBounds = YES;
                resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
                resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                [self addSubview:resizableImageView];
                _resizableImageView = resizableImageView;
                
                CGSize imageSize = img.size;
                
                CGRect screenBound = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenBound.size.width;
                CGFloat screenHeight = screenBound.size.height;
                
                // Calculate Min
                CGFloat xScale = screenWidth / imageSize.width;    // the scale needed to perfectly fit the image width-wise
                CGFloat yScale = screenHeight/ imageSize.height;  // the scale needed to perfectly fit the image height-wise
                CGFloat minScale = MIN(xScale, yScale);
                if (xScale >= 1 && yScale >= 1) {
                    minScale = 1.0;
                }
                
                CGFloat finalWidth = imageSize.width * minScale;
                CGFloat finalHeight = imageSize.height * minScale;
                CGRect finalImageViewFrame = CGRectMake((screenWidth - finalWidth) / 2, (screenHeight - finalHeight) / 2, finalWidth, finalHeight);
                [UIView animateWithDuration:0.35 animations:^{
                    resizableImageView.layer.frame = finalImageViewFrame;
                } completion:^(BOOL finished) {
                    if (finished) {
                        displayImageBlock();
                    }
                    [resizableImageView removeFromSuperview];
                }];
            } else {
                displayImageBlock();
            }
			
		} else  {

            // Show image failure
            [self displayImageFailure];
            [self setNeedsLayout];
			
		}
	}
}

// Image failed so just show black!
- (void)displayImageFailure {
    [self hideLoadingIndicator];
    _photoImageView.image = nil;
    
    // Show if image is not empty
    if (![_photo respondsToSelector:@selector(emptyImage)] || !_photo.emptyImage) {
        if (!_loadingError) {
            _loadingError = [UIImageView new];
            _loadingError.image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageError" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
            _loadingError.userInteractionEnabled = NO;
            _loadingError.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [_loadingError sizeToFit];
            [self addSubview:_loadingError];
        }
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    }
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

#pragma mark - Loading Progress

- (void)setProgressFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [notification object];
        id <MWPhoto> photoWithProgress = [dict objectForKey:@"photo"];
        if (photoWithProgress == self.photo) {
            float progress = [[dict valueForKey:@"progress"] floatValue];
            _loadingIndicator.progress = MAX(MIN(1, progress), 0);
            _inbilinProgressView.progress = MAX(MIN(1, progress), 0);
            if (!_inbilinProgressView.image &&
                ([self.photo conformsToProtocol:@protocol(MWProgressivePhoto)] && [(id <MWProgressivePhoto>)self.photo lowQualityImage])) {
                _inbilinProgressView.image = [(id <MWProgressivePhoto>)self.photo lowQualityImage];
                [self setNeedsLayout];
                [self layoutIfNeeded];
                NSLog(@"Error.");
            }
        }
    });
}

- (void)setLowQualityImageFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (notification.object == self.photo) {
            UIImage *lowQualityImage = [(id <MWProgressivePhoto>)self.photo lowQualityImage];
            _inbilinProgressView.image = lowQualityImage;
            if (_inbilinProgressView.hidden) {
                _inbilinProgressView.hidden = NO;
            }
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    });
}

- (void)hideLoadingIndicator {
    _loadingIndicator.hidden = YES;
    _inbilinProgressView.hidden = YES;
    _inbilinProgressView.progress = 0;
    _inbilinProgressView.image = nil;
}

- (void)showLoadingIndicator {
    self.zoomScale = 0;
    self.minimumZoomScale = 0;
    self.maximumZoomScale = 0;
    if (self.photo) {
        if ([self.photo conformsToProtocol:@protocol(MWProgressivePhoto)] && [(id <MWProgressivePhoto>)self.photo lowQualityImageURL]) {
            [self.photo underlyingImageExistsLocally:^(BOOL exists) {
                if (!exists) {
                    _inbilinProgressView.progress = 0;
                    _inbilinProgressView.hidden = NO;
                }
            }];
        } else {
            _loadingIndicator.progress = 0;
            _loadingIndicator.hidden = NO;
        }
    }
    [self hideImageFailure];
}

#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView && _photoBrowser.zoomPhotosToFill) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
	
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);

    }
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;
    
    // If it's a video then disable zooming
    if ([self displayingVideo]) {
        self.maximumZoomScale = self.zoomScale;
        self.minimumZoomScale = self.zoomScale;
    }

    // Layout
	[self setNeedsLayout];

}

#pragma mark -

- (void)layoutSubviews {
	
	// Update tap view frame
	_tapView.frame = self.bounds;
	
	// Position indicators (centre does not seem to work!)
	if (!_loadingIndicator.hidden)
        _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                         _loadingIndicator.frame.size.width,
                                         _loadingIndicator.frame.size.height);
	if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    if (!_inbilinProgressView.hidden) {
        [_inbilinProgressView sizeToFit];
        
        _inbilinProgressView.frame = CGRectMake(floorf((self.bounds.size.width - _inbilinProgressView.frame.size.width) / 2.),
                                             floorf((self.bounds.size.height - _inbilinProgressView.frame.size.height) / 2),
                                             _inbilinProgressView.frame.size.width,
                                             _inbilinProgressView.frame.size.height);
    }

	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
		_photoImageView.frame = frameToCenter;
	
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_photoBrowser hideControlsAfterDelay];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    if (_photoBrowser.mode == MWPhotoBrowserModeNormal ||
        _photoBrowser.mode == MWPhotoBrowserModeSelectPhoto ||
        _photoBrowser.mode == MWPhotoBrowserModeSelectedPhoto) {
        [_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
    } else if (_photoBrowser.mode == MWPhotoBrowserModePurePhoto) {
        [_photoBrowser performSelector:@selector(dismissUserInterface) withObject:nil afterDelay:0.2];
    }
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    // Dont double tap to zoom if showing a video
    if ([self displayingVideo]) {
        return;
    }
	
	// Cancel any single tap handling
	[NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
	
	// Zoom
	if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];

	}
	
	// Delay controls
	[_photoBrowser hideControlsAfterDelay];
	
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch { 
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleSingleTap:CGPointMake(touchX, touchY)];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

#pragma mark - Long Press Detection

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [_photoBrowser handleLongPress];
    }
}

@end
