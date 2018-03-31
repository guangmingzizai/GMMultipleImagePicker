//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <SDWebImage/SDWebImageCoder.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

@interface MWPhoto () {

    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
    PHImageRequestID _assetRequestID;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic) CGSize assetTargetSize;

- (void)imageLoadingComplete;

@end

@implementation MWPhoto

@synthesize underlyingImage = _underlyingImage; // synth property from protocol

@synthesize lowQualityImageURL = _lowQualityImageURL;
@synthesize lowQualityImage = _lowQualityImage;

#pragma mark - Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithURL:url];
}

+ (MWPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    return [[MWPhoto alloc] initWithAsset:asset targetSize:targetSize];
}

+ (MWPhoto *)videoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithVideoURL:url];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url lowQualityImageURL:(NSURL *)lowQualityImageURL
{
    return [[MWPhoto alloc] initWithURL:url lowQualityImageURL:lowQualityImageURL];
}

#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        self.emptyImage = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.photoURL = url;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url lowQualityImageURL:(NSURL *)lowQualityImageURL {
    if ((self = [super init])) {
        _photoURL = [url copy];
        _lowQualityImageURL = [lowQualityImageURL copy];
    }
    return self;
}

- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if ((self = [super init])) {
        self.asset = asset;
        self.assetTargetSize = targetSize;
        self.isVideo = asset.mediaType == PHAssetMediaTypeVideo;
    }
    return self;
}

- (id)initWithVideoURL:(NSURL *)url {
    if ((self = [super init])) {
        self.videoURL = url;
        self.isVideo = YES;
        self.emptyImage = YES;
    }
    return self;
}

#pragma mark - Video

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.isVideo = YES;
}

- (void)getVideoURL:(void (^)(NSURL *url))completion {
    if (_videoURL) {
        completion(_videoURL);
    } else if (_asset && _asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                completion(((AVURLAsset *)asset).URL);
            } else {
                completion(nil);
            }
        }];
    }
    return completion(nil);
}

#pragma mark - MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    if (!_underlyingImage && _image) {
        _underlyingImage = _image;
    }
    return _underlyingImage;
}

- (void)underlyingImageExistsLocally:(void (^)(BOOL exists))completion {
    if (self.underlyingImage) {
        completion(YES);
    } else if (_photoURL) {
        // Check what type of url it is
        if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            completion(YES);
        } else if ([_photoURL isFileReferenceURL] ||
                   [_photoURL isFileURL]) {
            completion(YES);
        } else {
            // Web image
            [[SDWebImageManager sharedManager] diskImageExistsForURL:_photoURL
                                                          completion:^(BOOL isInCache) {
                                                              completion(isInCache);
                                                          }];
        }
    } else {
        completion(NO);
    }
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self underlyingImageExistsLocally:^(BOOL exists) {
                if (exists) {
                    [self performLoadUnderlyingImageAndNotify];
                } else {
                    if (self.lowQualityImage) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOW_QUALITY_IMAGE_LOADED_NOTIFICATION
                                                                            object:self];
                        [self performLoadUnderlyingImageAndNotify];
                    } else {
                        if (self.lowQualityImageURL) {
                            [self _downloadImageWithURL:self.lowQualityImageURL retry:0 completion:^(UIImage *image, BOOL success){
                                if (success) {
                                    _lowQualityImage = image;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOW_QUALITY_IMAGE_LOADED_NOTIFICATION
                                                                                        object:self];
                                    [self performLoadUnderlyingImageAndNotify];
                                } else {
                                    _webImageOperation = nil;
                                    [self imageLoadingComplete];
                                }
                            }];
                        } else {
                            [self performLoadUnderlyingImageAndNotify];
                        }
                    }
                }
            }];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        // Check what type of url it is
        if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            
            // Load from assets library
            [self _performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL: _photoURL];
            
        } else if ([_photoURL isFileReferenceURL] ||
                   [_photoURL isFileURL]) {
            
            // Load from local file async
            [self _performLoadUnderlyingImageAndNotifyWithLocalFileURL: _photoURL];
            
        } else {
            
            // Load async from web (using SDWebImage)
            [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
            
        }
        
    } else if (_asset) {
        
        // Load from photos asset
        [self _performLoadUnderlyingImageAndNotifyWithAsset: _asset targetSize:_assetTargetSize];
        
    } else {
        
        // Image is empty
        [self imageLoadingComplete];
        
    }
}

// Load from local file
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager loadImageWithURL:url
                                               options:SDWebImageRetryFailed
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                  if (expectedSize > 0) {
                                                      float progress = receivedSize / (float)expectedSize;
                                                      NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                            [NSNumber numberWithFloat:progress], @"progress",
                                                                            self, @"photo", nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                                                  }
                                              } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                  if (error) {
                                                      MWLog(@"SDWebImage failed to download image: %@", error);
                                                  }
                                                  _webImageOperation = nil;
                                                  self.underlyingImage = image;
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self imageLoadingComplete];
                                                  });
                                              }];
    } @catch (NSException *e) {
        MWLog(@"Photo from web: %@", e);
        _webImageOperation = nil;
        [self imageLoadingComplete];
    }
}

// Load from local file
- (void)_performLoadUnderlyingImageAndNotifyWithLocalFileURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                self.underlyingImage = [UIImage imageWithContentsOfFile:url.path];
                if (!_underlyingImage) {
                    MWLog(@"Error loading photo from path: %@", url.path);
                }
            } @finally {
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

// Load from asset library async
- (void)_performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:url
                               resultBlock:^(ALAsset *asset){
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullScreenImage];
                                   if (iref) {
                                       self.underlyingImage = [UIImage imageWithCGImage:iref];
                                   }
                                   [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                               }
                              failureBlock:^(NSError *error) {
                                  self.underlyingImage = nil;
                                  MWLog(@"Photo from asset library error: %@",error);
                                  [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                              }];
            } @catch (NSException *e) {
                MWLog(@"Photo from asset library error: %@", e);
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

// Load from photos library
- (void)_performLoadUnderlyingImageAndNotifyWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble: progress], @"progress",
                              self, @"photo", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
    };
    
    _assetRequestID = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.underlyingImage = result;
            [self imageLoadingComplete];
        });
    }];

}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
	self.underlyingImage = nil;
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading {
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    } else if (_assetRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetRequestID];
        _assetRequestID = PHInvalidImageRequestID;
    }
}

#pragma mark - Helper

- (void)_downloadImageWithURL:(NSURL *)imageURL retry:(NSInteger)retry completion:(void (^)(UIImage *image, BOOL success))completion
{
    NSAssert(retry < 5, @"Prevent stack overflowing");
    __block NSInteger retryTime = retry;
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager loadImageWithURL:imageURL
                                               options:SDWebImageRetryFailed
                                              progress:nil
                                             completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                 if (error && !image) {
                                                     MWLog(@"SDWebImage failed to download image: %@", error);
                                                     if (retryTime > 0) {
                                                         retryTime--;
                                                         [self _downloadImageWithURL:imageURL retry:retryTime completion:completion];
                                                         return;
                                                     }
                                                 }
                                                 if (completion) {
                                                     completion(image, !error && image);
                                                 }
                                             }];
    } @catch (NSException *e) {
        MWLog(@"Photo from web: %@", e);
        if (completion) {
            completion(nil, NO);
        }
    }
    
}

@end
