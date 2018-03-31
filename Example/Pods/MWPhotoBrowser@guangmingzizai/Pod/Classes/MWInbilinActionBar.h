//
//  MWInbilinActionBar.h
//  Pods
//
//  Created by 柬斐 王 on 15/9/29.
//
//

#import <UIKit/UIKit.h>

@class MWPhotoBrowser;
@interface MWInbilinActionBar : UIView

- (instancetype)initWithFrame:(CGRect)frame photoBrowser:(MWPhotoBrowser *)photoBrowser;
- (void)updateData:(NSUInteger)index;

@end
