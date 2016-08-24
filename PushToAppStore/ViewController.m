//
//  ViewController.m
//  PushToAppStore
//
//  Created by pactera on 16/8/16.
//  Copyright © 2016年 com.storyboard.pactera. All rights reserved.
//

#import "ViewController.h"
#import "QPushToAppStore.h"
#import "KaneVersionManager.h"

static NSString *ID = @"Cell";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, copy) NSString *text;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"cellTest";
    if (indexPath.row==0) {
        cell.textLabel.text = @"友情评价";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"检测版本";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"hhh%ld",indexPath.row);
    if (indexPath.row==0) {
        [[QPushToAppStore shareInstance]showGotoAppStore];
    } else if (indexPath.row == 1) {
        [[KaneVersionManager shareInstance]checkVersion:1];
    }
    
}

//修改cell separatorStyleSingleLine 长度
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}


@end
