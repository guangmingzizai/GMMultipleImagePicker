//
//  BLPhotoUtils.m
//  BiLin
//
//  Created by devduwan on 15/10/9.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLPhotoUtils.h"

static NSInteger _haveUseCount = 0;
static NSInteger _willUseCount = 0;

@implementation BLPhotoUtils

+ (void)setUseCount:(NSInteger) count {
    _haveUseCount = count;
}

+ (NSInteger)getUseCount {
    return _haveUseCount;
}

+ (void)setWillUseCount:(NSInteger) count {
    _willUseCount = count;
}

+ (NSInteger)getWillUseCount {
    return _willUseCount;
}

@end
