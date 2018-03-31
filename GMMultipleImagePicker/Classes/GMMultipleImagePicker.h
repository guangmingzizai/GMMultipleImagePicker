//
//  GMMultipleImagePicker.h
//  GMMultipleImagePicker
//
//  Created by wangjianfei on 2018/1/2.
//

#import <Foundation/Foundation.h>
#import "GMMultipleImagePickerResponse.h"

typedef void (^GMResponseSenderBlock)(NSError * _Nullable error, NSArray<GMMultipleImagePickerResponse *> * _Nullable response);

@interface GMMultipleImagePicker : NSObject

+ (nonnull instancetype)sharedInstance;

- (void)launchCamera:(nonnull NSDictionary *)options callback:(nonnull GMResponseSenderBlock)callback;
- (void)launchSingleImagePicker:(nonnull NSDictionary *)options callback:(nonnull GMResponseSenderBlock)callback;
- (void)launchMultipleImagePicker:(nonnull NSDictionary *)options callback:(nonnull GMResponseSenderBlock)callback;

@end
