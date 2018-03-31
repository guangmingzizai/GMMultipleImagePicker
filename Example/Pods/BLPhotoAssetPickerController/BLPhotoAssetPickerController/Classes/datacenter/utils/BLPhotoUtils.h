//
//  BLPhotoUtils.h
//  BiLin
//
//  Created by devduwan on 15/10/9.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLPhotoUtils : NSObject

+ (void)setUseCount:(NSInteger) count;
+ (NSInteger)getUseCount;

+ (void)setWillUseCount:(NSInteger) count;
+ (NSInteger)getWillUseCount;

@end
