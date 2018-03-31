//
//  MWInbilinSelectionToolBar.h
//  Pods
//
//  Created by 柬斐 王 on 15/10/4.
//
//

#import <UIKit/UIKit.h>

@interface MWInbilinSelectionToolBar : UIView

- (void)setSelectionCount:(NSUInteger)selectionCount;
- (void)addFinishButtonTarget:(id)target action:(SEL)action;

@end
