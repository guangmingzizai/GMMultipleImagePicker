//
//  GMMultipleImagePickerResponse.h
//  ActionSheetPicker-3.0
//
//  Created by wangjianfei on 2018/1/2.
//

#import <UIKit/UIKit.h>

@interface GMMultipleImagePickerResponse : NSObject

@property (copy, nonatomic, nullable) NSString *data; //base64 string
@property (strong, nonatomic, nullable) UIImage *image;
@property (assign, nonatomic) BOOL isVertical;
@property (copy, nonatomic, nonnull) NSString *uri; //file path
@property (copy, nonatomic, nullable) NSString *origURL;
@property (strong, nonatomic, nullable) NSNumber *fileSize;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

@end
