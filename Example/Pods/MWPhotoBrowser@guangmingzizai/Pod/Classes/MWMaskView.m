//
//  MWMaskView.m
//  Pods
//
//  Created by 柬斐 王 on 15/10/9.
//
//

#import "MWMaskView.h"

@implementation MWMaskView

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    } else {
        return hitView;
    }
}

@end
