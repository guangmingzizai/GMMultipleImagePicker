#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSFileManager+GMAdditions.h"
#import "UIImage+GMAdditions.h"
#import "UIViewController+GMAdditions.h"
#import "GMMultipleImagePicker.h"
#import "GMMultipleImagePickerResponse.h"
#import "GMPermission.h"

FOUNDATION_EXPORT double GMMultipleImagePickerVersionNumber;
FOUNDATION_EXPORT const unsigned char GMMultipleImagePickerVersionString[];

