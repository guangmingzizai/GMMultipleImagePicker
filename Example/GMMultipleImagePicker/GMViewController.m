//
//  GMViewController.m
//  GMMultipleImagePicker
//
//  Created by guangmingzizai@qq.com on 01/02/2018.
//  Copyright (c) 2018 guangmingzizai@qq.com. All rights reserved.
//

#import "GMViewController.h"
#import "GMMultipleImagePickerResponse.h"

@interface GMViewController ()

@end

@implementation GMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(onclick) forControlEvents:UIControlEventTouchDown];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)onclick {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@(0.4) forKey:@"quality"];
    [dic setValue:@(YES) forKey:@"allowsEditing"];
    [dic setValue:@(true) forKey:@"noData"];
    [dic setValue:@(true) forKey:@"cameraEnable"];
    [dic setValue:@{@"skipBackup": @(true)} forKey:@"storageOptions"];
    
    [GMMultipleImagePicker.sharedInstance launchMultipleImagePicker:dic callback:^(NSError * _Nullable error, NSArray<GMMultipleImagePickerResponse *> * _Nullable response) {
        [self createImgView:response];
    }];
}

- (void)createImgView:(NSArray *)responses {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (GMMultipleImagePickerResponse *data in responses) {
            NSInteger index = [responses indexOfObject:data];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(index*50+10*index, 150, 50, 50)];
            imgView.image = data.image;
            [self.view addSubview:imgView];
        }
    });
}

@end
