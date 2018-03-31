//
//  BLAssetPickerController.m
//  BiLin
//
//  Created by devduwan on 15/9/23.
//  Copyright © 2015年 inbilin. All rights reserved.
//

#import "BLPhotoAssetNavigationController.h"
#import "Constants.h"

#define kPopoverContentSize CGSizeMake(UI_SCREEN_WIDTH, 480)

@interface BLPhotoAssetNavigationController ()

@end

@implementation BLPhotoAssetNavigationController


- (id)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        self.preferredContentSize=kPopoverContentSize;
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
