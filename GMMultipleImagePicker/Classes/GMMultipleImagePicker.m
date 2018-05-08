//
//  GMMultipleImagePicker.m
//  GMMultipleImagePicker
//
//  Created by wangjianfei on 2018/1/2.
//

#import "GMMultipleImagePicker.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "GMPermission.h"
#import "UIImage+GMAdditions.h"
#import "GMPermission.h"
#import "NSFileManager+GMAdditions.h"
#import "UIViewController+GMAdditions.h"
#import <BLPhotoAssetPickerController/BLPhotoAssetPickerController.h>
#import <BLPhotoAssetPickerController/BLPhotoUtils.h>
#import <BLPhotoAssetPickerController/MBProgressHUD+Add.h>
#import <BLPhotoAssetPickerController/BLPhotoDataCenter.h>
#import <RMUniversalAlert/RMUniversalAlert.h>

NSDictionary<NSString *, id> *GMMakeError(NSString *message,
                                           id __nullable toStringify,
                                           NSDictionary<NSString *, id> *__nullable extraData)
{
    if (toStringify) {
        message = [message stringByAppendingString:[toStringify description]];
    }
    
    NSMutableDictionary<NSString *, id> *error = [extraData mutableCopy] ?: [NSMutableDictionary new];
    error[@"message"] = message;
    return error;
}

NSError *MakeError(NSString *message,
                   id __nullable toStringify,
                   NSDictionary<NSString *, id> *__nullable extraData)
{
    if (toStringify) {
        message = [message stringByAppendingString:[toStringify description]];
    }
    
    NSMutableDictionary<NSString *, id> *error = [extraData mutableCopy] ?: [NSMutableDictionary new];
    error[@"message"] = message;
    return [NSError errorWithDomain:@"" code:0 userInfo:error];
}

@interface GMMultipleImagePicker() <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, BLPhotoAssetPickerControllerDelegate>

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) GMResponseSenderBlock callback;
@property (nonatomic, strong) NSDictionary *defaultOptions;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, strong) NSArray *customButtons;

@end

@implementation GMMultipleImagePicker {
    MBProgressHUD *_uploadHud;
    NSArray<NSNumber *> *_requestImageIdArray;
}

+ (instancetype)sharedInstance {
    static GMMultipleImagePicker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GMMultipleImagePicker new];
    });
    return instance;
}

- (void)launchCamera:(NSDictionary *)options callback:(GMResponseSenderBlock)callback
{
    self.options = [options mutableCopy];
    self.callback = callback;
    
#if TARGET_IPHONE_SIMULATOR
    self.callback(MakeError(@"CAMERA_NOT_SUPPORT", nil, nil), nil);
    return;
#else
    // Check permissions
    [GMPermission checkCameraPermissions:^(BOOL granted) {
        if (!granted) {
            self.callback(MakeError(@"NO_CAMERA_PERMISSION", nil, nil), nil);
            return;
        }
        
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([[self.options objectForKey:@"cameraType"] isEqualToString:@"front"]) {
            self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        else { // "back"
            self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
        self.picker.mediaTypes = @[(NSString *)kUTTypeImage];
        
        if ([[self.options objectForKey:@"allowsEditing"] boolValue]) {
            self.picker.allowsEditing = true;
        }
        self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.picker.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *root = [UIViewController gm_toppestPresentedViewController];
            [root presentViewController:self.picker animated:YES completion:nil];
        });
    }];
#endif
}

- (void)launchSingleImagePicker:(NSDictionary *)options callback:(GMResponseSenderBlock)callback
{
    self.options = [options mutableCopy];
    self.callback = callback;
    
    [GMPermission checkPhotosPermissions:^(BOOL granted) {
        if (!granted) {
            self.callback(MakeError(@"NO_PHOTO_ALBUM_PERMISSION", nil, nil), nil);
            return;
        }
        
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.picker.mediaTypes = @[(NSString *)kUTTypeImage];
        
        if ([[self.options objectForKey:@"allowsEditing"] boolValue]) {
            self.picker.allowsEditing = true;
        }
        self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.picker.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *root = [UIViewController gm_toppestPresentedViewController];
            [root presentViewController:self.picker animated:YES completion:nil];
        });
    }];
}

- (void)launchMultipleImagePicker:(NSDictionary *)options callback:(GMResponseSenderBlock)callback
{
    self.options = [options mutableCopy];
    self.callback = callback;
    
    [GMPermission checkPhotosPermissions:^(BOOL granted) {
        if (!granted) {
            self.callback(MakeError(@"NO_PHOTO_ALBUM_PERMISSION", nil, nil), nil);
            return;
        }
        
        BLPhotoAssetPickerController *assetPickerViewController = [[BLPhotoAssetPickerController alloc] init];
        assetPickerViewController.maxSelectionNum = (self.options[@"maxSelectionNum"] ? [self.options[@"maxSelectionNum"] integerValue] : 9);
        assetPickerViewController.cameraEnable = (self.options[@"cameraEnable"] ? [self.options[@"cameraEnable"] boolValue] : NO);
        assetPickerViewController.delegate = self;
        
        BLPhotoAssetNavigationController *pickerNavigationController = [[BLPhotoAssetNavigationController alloc] initWithRootViewController:assetPickerViewController];
        [BLPhotoUtils setUseCount:0];
        [BLPhotoUtils setWillUseCount:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *root = [UIViewController gm_toppestPresentedViewController];
            [root presentViewController:pickerNavigationController animated:YES completion:nil];
        });
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // iOS 11，allowsEditing为true时，图片可能有黑边
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        navigationController.navigationBar.translucent = true;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_block_t dismissCompletionBlock = ^{
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        
        // We default to path to the temporary directory
        NSString *path = [self _defaultCachePathForImageURL:imageURL mediaType:mediaType];
        
        // If storage options are provided, we use the documents directory which is persisted
        NSError *error = nil;
        path = [self _resetCachePathIfNeeded:path error:&error];
        if (error) {
            self.callback(MakeError(@"CREATE_CACHE_DIR_FAILED", nil, nil), nil);
            return;
        }
        
        UIImage *image;
        if ([[self.options objectForKey:@"allowsEditing"] boolValue]) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }
        else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        // GIFs break when resized, so we handle them differently
        if (imageURL && [[imageURL absoluteString] rangeOfString:@"ext=GIF"].location != NSNotFound) {
            [self _gitResponseForImage:image imageURL:imageURL cachePath:path completionBlock:^(NSError *error, GMMultipleImagePickerResponse *response) {
                if (error) {
                    self.callback(MakeError(@"ACCESS_IMAGE_FAILED", nil, nil), nil);
                } else {
                    self.callback(nil, @[response]);
                }
            }];
        } else {
            [self _responseForImage:image needDownscale:YES imageURL:imageURL cachePath:path completionBlock:^(NSError *error, GMMultipleImagePickerResponse *response) {
                if (error) {
                    self.callback(MakeError(@"ACCESS_IMAGE_FAILED", nil, nil), nil);
                } else {
                    self.callback(nil, @[response]);
                }
            }];
        }
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:dismissCompletionBlock];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:^{
            if (self.callback) {
                self.callback(MakeError(@"CANCELLED", nil, nil), nil);
                self.callback = nil;
            }
        }];
    });
}

- (void)savedImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        NSLog(@"Error while saving picture into photo album");
    } else {
        // when the image has been saved in the photo album
    }
}

- (NSString *)_defaultCachePathForAsset:(nullable PHAsset *)asset {
    NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".jpg"];
    return [[NSTemporaryDirectory() stringByStandardizingPath] stringByAppendingPathComponent:fileName];
}

- (NSString *)_defaultCachePathForImageURL:(NSURL *)imageURL mediaType:(NSString *)mediaType {
    NSString *fileName;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSString *tempFileName = [[NSUUID UUID] UUIDString];
        if (imageURL && [[imageURL absoluteString] rangeOfString:@"ext=GIF"].location != NSNotFound) {
            fileName = [tempFileName stringByAppendingString:@".gif"];
        }
        else if ([[[self.options objectForKey:@"imageFileType"] stringValue] isEqualToString:@"png"]) {
            fileName = [tempFileName stringByAppendingString:@".png"];
        }
        else {
            fileName = [tempFileName stringByAppendingString:@".jpg"];
        }
    }
    return [[NSTemporaryDirectory() stringByStandardizingPath] stringByAppendingPathComponent:fileName];
}

- (NSString *)_resetCachePathIfNeeded:(NSString *)path error:(NSError **)error {
    if ([self.options objectForKey:@"storageOptions"] && [[self.options objectForKey:@"storageOptions"] isKindOfClass:[NSDictionary class]]) {
        NSString *fileName = [path lastPathComponent];
        NSDictionary *storageOptions = [self.options objectForKey:@"storageOptions"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        // Creates documents subdirectory, if provided
        if ([storageOptions objectForKey:@"path"]) {
            NSString *newPath = [documentsDirectory stringByAppendingPathComponent:[storageOptions objectForKey:@"path"]];
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:error];
            if (*error == nil) {
                path = [newPath stringByAppendingPathComponent:fileName];
            }
        } else {
            path = [documentsDirectory stringByAppendingPathComponent:fileName];
        }
    }
    return path;
}

- (void)_gitResponseForImage:(UIImage *)image imageURL:(NSURL *)imageURL cachePath:(NSString *)cachePath completionBlock:(void (^)(NSError *error, GMMultipleImagePickerResponse *response))completionBlock {
    ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:imageURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        [data writeToFile:cachePath atomically:YES];
        
        GMMultipleImagePickerResponse *response = [GMMultipleImagePickerResponse new];
        response.width = image.size.width;
        response.height = image.size.height;
        response.isVertical = (image.size.width < image.size.height);
        response.image = image;
        
        if (![[self.options objectForKey:@"noData"] boolValue]) {
            response.data = [data base64EncodedStringWithOptions:0];
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:cachePath];
        response.uri = [fileURL absoluteString];
        
        // add ref to the original image
        NSString *origURL = [imageURL absoluteString];
        if (origURL) {
            response.origURL = origURL;
        }
        
        NSNumber *fileSizeValue = nil;
        NSError *fileSizeError = nil;
        [fileURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&fileSizeError];
        if (fileSizeValue){
            response.fileSize = fileSizeValue;
        }
        completionBlock(nil, response);
    } failureBlock:^(NSError *error) {
        completionBlock(error, nil);
    }];
}

- (void)_responseForImage:(UIImage *)image needDownscale:(BOOL)needDownscale imageURL:(NSURL *)imageURL cachePath:(NSString *)cachePath completionBlock:(void (^)(NSError *error, GMMultipleImagePickerResponse *response))completionBlock {
    GMMultipleImagePickerResponse *response = [GMMultipleImagePickerResponse new];
    
    // GIFs break when resized, so we handle them differently
    image = [UIImage gm_fixOrientation:image];  // Rotate the image for upload to web
    
    // If needed, downscale image
    float maxWidth = 800;
    float maxHeight = 1280;
    if ([self.options valueForKey:@"maxWidth"]) {
        maxWidth = [[self.options valueForKey:@"maxWidth"] floatValue];
    }
    if ([self.options valueForKey:@"maxHeight"]) {
        maxHeight = [[self.options valueForKey:@"maxHeight"] floatValue];
    }
    image = [UIImage gm_downscaleImageIfNecessary:image maxWidth:maxWidth maxHeight:maxHeight];
    
    NSData *data;
    if ([[[self.options objectForKey:@"imageFileType"] stringValue] isEqualToString:@"png"]) {
        data = UIImagePNGRepresentation(image);
    }
    else {
        data = UIImageJPEGRepresentation(image, [[self.options valueForKey:@"quality"] floatValue]);
    }
    [data writeToFile:cachePath atomically:YES];
    
    if (![[self.options objectForKey:@"noData"] boolValue]) {
        response.data = [data base64EncodedStringWithOptions:0]; // base64 encoded image string
    }
    if (![[self.options objectForKey:@"noImage"] boolValue]) {
        response.image = image;
    }
    
    BOOL vertical = (image.size.width < image.size.height) ? YES : NO;
    response.isVertical = vertical;
    NSURL *fileURL = [NSURL fileURLWithPath:cachePath];
    NSString *filePath = [fileURL absoluteString];
    response.uri = filePath;
    
    // add ref to the original image
    NSString *origURL = [imageURL absoluteString];
    if (origURL) {
        response.origURL = origURL;
    }
    
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [fileURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&fileSizeError];
    if (fileSizeValue){
        response.fileSize = fileSizeValue;
    }
    
    response.width = image.size.width;
    response.height = image.size.height;
    
    NSDictionary *storageOptions = [self.options objectForKey:@"storageOptions"];
    if (storageOptions && [[storageOptions objectForKey:@"cameraRoll"] boolValue] == YES && self.picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([[storageOptions objectForKey:@"waitUntilSaved"] boolValue]) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedImage : hasBeenSavedInPhotoAlbumWithError : usingContextInfo :), (__bridge void * _Nullable)(response));
        } else {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }
    
    // If storage options are provided, check the skipBackup flag
    if ([self.options objectForKey:@"storageOptions"] && [[self.options objectForKey:@"storageOptions"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *storageOptions = [self.options objectForKey:@"storageOptions"];
        
        if ([[storageOptions objectForKey:@"skipBackup"] boolValue]) {
            [NSFileManager gm_addSkipBackupAttributeToItemAtPath:cachePath]; // Don't back up the file to iCloud
        }
        
        if (![[storageOptions objectForKey:@"waitUntilSaved"] boolValue]) {
            completionBlock(nil, response);
        }
    }
    else {
        completionBlock(nil, response);
    }
}

#pragma mark - BLPhotoAssetPickerControllerDelegate

- (void)photoAssetPickerController:(BLPhotoAssetPickerController *)picker didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
    [self photoAssetPickerController:picker didFinishTakingPhoto:nil andPickingAssets:assets];
}

- (void)photoAssetPickerControllerDidCancel:(BLPhotoAssetPickerController *)picker {
    if (self.callback) {
        self.callback(MakeError(@"CANCELLED", nil, nil), nil);
        self.callback = nil;
    }
}

- (void)photoAssetPickerController:(BLPhotoAssetPickerController *)picker didFinishTakingPhoto:(UIImage *)image andPickingAssets:(NSArray *)assets {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block NSInteger fetchData = 0;
    float maxWidth = 800;
    float maxHeight = 1280;
    if ([self.options valueForKey:@"maxWidth"]) {
        maxWidth = [[self.options valueForKey:@"maxWidth"] floatValue];
    }
    if ([self.options valueForKey:@"maxHeight"]) {
        maxHeight = [[self.options valueForKey:@"maxHeight"] floatValue];
    }
    [BLPhotoDataCenter requestImagesForAssets:assets maxSize:CGSizeMake(maxWidth, maxHeight) completionBlock:^(NSArray<UIImage *> *images) {
        fetchData = 1;
        
        [_uploadHud hideAnimated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           NSArray<UIImage *> *targetImages = [images copy];
                           if (image != nil) {
                               targetImages = [targetImages arrayByAddingObject:image];
                           }
                           [self _handleMultipleImagePickerResult:images];
                       });
    } requestIDsBlock:^(NSArray<NSNumber *> *requestArray) {
        _requestImageIdArray = requestArray;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (fetchData == 0) {
            _uploadHud = [MBProgressHUD showProcessTip:@"正在加载..."];
            [_uploadHud addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelLoadThumbnailAlert)]];
        }
    });
}


- (void)cancelLoadThumbnailAlert {
    __weak typeof(self) weakSelf = self;
    [RMUniversalAlert showAlertInViewController:[UIViewController gm_toppestPresentedViewController]
                                      withTitle:@"取消图片加载？"
                                        message:nil
                              cancelButtonTitle:@"否"
                         destructiveButtonTitle:@"是"
                              otherButtonTitles:nil
                                       tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                           __strong typeof(self) strongSelf = weakSelf;
                                           if (buttonIndex != alert.cancelButtonIndex) {
                                               [strongSelf cancelLoadThumbnail];
                                           }
                                       }];
}

- (void)cancelLoadThumbnail {
    [_uploadHud hideAnimated:YES];
    if (_requestImageIdArray && _requestImageIdArray.count >0) {
        for (int i = 0; i<_requestImageIdArray.count; i++) {
            [[PHImageManager defaultManager] cancelImageRequest:[[_requestImageIdArray objectAtIndex:i] intValue]];
        }
    }
    _requestImageIdArray = nil;
    [BLPhotoUtils setUseCount:0];
    [BLPhotoUtils setWillUseCount:0];
    
    if (self.callback) {
        self.callback(MakeError(@"CANCELLED", nil, nil), nil);
        self.callback = nil;
    }
}

- (void)_handleMultipleImagePickerResult:(NSArray<UIImage *> *)images {
    NSMutableDictionary *resultImageInfos = [NSMutableDictionary dictionaryWithCapacity:images.count];
    for (int i = 0; i < images.count; i++) {
        UIImage *image = images[i];
        
        NSString *cachePath = [self _defaultCachePathForAsset: nil];
        NSError *error = nil;
        cachePath = [self _resetCachePathIfNeeded:cachePath error:&error];
        if (error) {
            if (self.callback) {
                self.callback(MakeError(@"CREATE_CACHE_DIR_FAILED", nil, nil), nil);
                self.callback = nil;
            }
            break;
        }
        
        [self _responseForImage:image needDownscale:NO imageURL:nil cachePath:cachePath completionBlock:^(NSError *error, GMMultipleImagePickerResponse *response) {
            if (error) {
                if (self.callback) {
                    self.callback(MakeError(@"ACCESS_IMAGE_FAILED", nil, nil), nil);
                    self.callback = nil;
                }
            } else {
                resultImageInfos[@(i)] = response;
                
                if (resultImageInfos.count == images.count) {
                    NSMutableArray *results = [NSMutableArray arrayWithCapacity:images.count];
                    for (int j = 0; j < images.count; j++) {
                        [results addObject:resultImageInfos[@(j)]];
                    }
                    if (self.callback) {
                        self.callback(nil, results);
                        self.callback = nil;
                    }
                }
            }
        }];
    }
}

@end
