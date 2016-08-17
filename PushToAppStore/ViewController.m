//
//  ViewController.m
//  PushToAppStore
//
//  Created by pactera on 16/8/16.
//  Copyright © 2016年 com.storyboard.pactera. All rights reserved.
//

#import "ViewController.h"
#import "QPushToAppStore.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[QPushToAppStore sharePushToAppStpre] showGotoAppStore];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
