//
//  MBProgressHUD+Add.m
//  BiLin
//
//  Created by Liu Feng on 14-5-21.
//  Copyright (c) 2014年 inbilin. All rights reserved.
//

#import "MBProgressHUD+Add.h"
#import "UIWindow+BLUtility.h"

@implementation MBProgressHUD (Add)

+ (instancetype)showProcessTip:(NSString *)tip {
    [self hideProcessTip];
    return [MBProgressHUD showHUDAddedTo:[UIWindow bl_mainWindow] animated:YES withTitle:tip];
}

+ (instancetype)showProcessTip:(NSString *)tip inView:(UIView *)superview {
    [self hideProcessTip:superview];
    return [MBProgressHUD showHUDAddedTo:superview animated:YES withTitle:tip];
}

+ (void)showProcessTip:(NSString *)tip offY:(CGFloat)y {
    [self hideProcessTip];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD showHUDAddedTo:[UIWindow bl_mainWindow] animated:YES withTitle:tip moveY:y];
    });
}

+ (void)hideProcessTip {
    [MBProgressHUD hideHUDsForViews:[UIApplication sharedApplication].windows animated:NO];
}

+ (void)hideProcessTip:(UIView *)superview {
    [MBProgressHUD hideHUDsForViews:@[superview] animated:NO];
}

+ (void)showSuccessTip:(NSString *)tip {
    [self hideProcessTip];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD showHUDInKeyWindowWithImage:@"ico_send_success" text:tip duration:1];
    });
}

+ (void)showFailTip:(NSString *)tip {
    [self hideProcessTip];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD showHUDInKeyWindowWithImage:@"ico_send_fail" text:tip duration:1];
    });
}

+ (void)showFailTipInFront:(NSString *)tip{
    [CATransaction begin];
    UIWindow *win = [UIWindow bl_mainWindow];
    [MBProgressHUD hideHUDForView:win animated:NO];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:win];
    [win addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_send_fail"]];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = tip;
    [HUD showAnimated:YES];
    [CATransaction commit];
    [HUD hideAnimated:YES afterDelay:1.5];
}

+ (void)showTip:(NSString *)tip {
    [self showTip:tip duration:2];
}

+ (void)showTip:(NSString *)tip duration:(CGFloat)duration {
    UIWindow *window = [UIWindow bl_mainWindow];
    [MBProgressHUD hideAllHUDsForView:window animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    if (tip.length > 10) {
        hud.detailsLabel.text = tip;
        hud.detailsLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        hud.label.text = tip;
    }
    [hud hideAnimated:YES afterDelay:duration];
}

+ (void)showHUDInFrontWindowWithImage:(NSString *)imageName text:(NSString *)text detailText:(NSString *)detailsText detailFont:(UIFont *)detailsFont duration:(float)duration{
    [CATransaction begin];
    UIWindow *keyWindow = [UIWindow bl_mainWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:keyWindow];
    [HUD setUserInteractionEnabled:YES];
    [keyWindow addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = text;
    HUD.detailsLabel.text = detailsText;
    HUD.detailsLabel.font = detailsFont;
    [HUD showAnimated:YES];
    [CATransaction commit];
    [HUD hideAnimated:YES afterDelay:duration];
}

+ (instancetype )showHUDAddedTo:(UIView *)view animated:(BOOL)animated withTitle:(NSString *)title
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.label.text = title;
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated withTitle:(NSString *)title moveY:(CGFloat) offY
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.label.text = title;
    [hud setCenter:CGPointMake(hud.center.x, hud.center.y+offY)];
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}

+ (void)hideHUDsForViews:(NSArray *)views animated:(BOOL)animated
{
    for (UIView *subview in views) {
        [MBProgressHUD hideAllHUDsForView:subview animated:animated];
    }
}

+ (instancetype)showHUDInKeyWindowWithImage:(NSString *)imageName text:(NSString *)text duration:(float)duration {
    
    UIWindow *win = [UIWindow bl_mainWindow];
    [MBProgressHUD hideHUDForView:win  animated:NO];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:win];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = text;
    
    [win addSubview:HUD];
    [HUD showAnimated:YES];
    
    [HUD hideAnimated:YES afterDelay:duration];
    return HUD;
}

+ (instancetype)showHUDInKeyWindowWithImage:(NSString *)imageName text:(NSString *)text detailText:(NSString *)detailsText detailFont:(UIFont *)detailsFont duration:(float)duration {
    
    UIWindow *mainWindown = [UIWindow bl_mainWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:mainWindown];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = text;
    HUD.detailsLabel.text = detailsText;
    HUD.detailsLabel.font = detailsFont;
    
    [mainWindown addSubview:HUD];
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:duration];
    
    return HUD;
}

@end
