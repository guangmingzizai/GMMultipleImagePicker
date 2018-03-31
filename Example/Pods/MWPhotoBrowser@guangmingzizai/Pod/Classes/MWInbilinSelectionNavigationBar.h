//
//  MWInbilinSelectionNavigationBar.h
//  Pods
//
//  Created by 柬斐 王 on 15/9/30.
//
//

#import <UIKit/UIKit.h>

@interface MWInbilinSelectionNavigationBar : UIView

- (void)addBackButtonTarget:(id)target selector:(SEL)selector;
- (void)addSelectButtonTarget:(id)target selector:(SEL)selector;
- (void)updateSelectButton:(BOOL)isSelected;

@end
