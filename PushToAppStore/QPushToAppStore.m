//
//  QPushToAppStore.m
//  PushToAppStore
//
//  Created by pactera on 16/8/16.
//  Copyright © 2016年 com.storyboard.pactera. All rights reserved.
//

#import "QPushToAppStore.h"
#import <StoreKit/StoreKit.h>


//判断时间 点击了对应的按钮所需的天数 下次弹出appstore对话框
#define ShowRefusalDay 0
#define ShowComplaintsDay 8
#define ShowPraiseDay 16
#define APPSTORE_UEL @"itms-apps://itunes.apple.com/us/app/lao-you/id1142134162?l=zh&ls=1&mt=8"

//上传打开时间
NSString *const LastOpenData = @"lastOpenData";
//上次版本
NSString *const LastVersion = @"LastVersion";
//上传选择状态
NSString *const LastSelectState = @"LastSelectState";

@interface QPushToAppStore()<SKStoreProductViewControllerDelegate> {
    UIAlertController *alertController;
}
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *message;

@end
@implementation QPushToAppStore

+ (QPushToAppStore*)shareInstance {
    static QPushToAppStore *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    return sharedObject;
}

- (void)showGotoAppStore {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //当前版本
    CGFloat currentVerson = [infoDict[@"CFBundleShortVersionString"] floatValue];
    //上次打开的时间   上次打开的版本  上次选择的选项
    NSDate *lastOpenDate = [userDefault objectForKey:LastOpenData];
    CGFloat lastVersion = [userDefault floatForKey:LastVersion];
    NSString *lastSelectState =[userDefault stringForKey:LastSelectState];
    //存储打开的时间 和 版本
    [userDefault setFloat:currentVerson forKey:LastVersion];
    [userDefault synchronize];
    
    if (lastOpenDate == nil || currentVerson != lastVersion) {
        //第一次打开 和 当前版本不对应（证明客户升级版本了）
        [userDefault setObject:[NSDate date] forKey:LastOpenData];
        [userDefault removeObjectForKey:LastSelectState];
        return;
    }
    
    //比较时间值
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitDay fromDate:lastOpenDate toDate:[NSDate date] options:0];
    NSInteger disDay = component.day;
    //判断用户上一次选择的状态
    //1残忍拒绝
    //2我要吐槽
    //3我要赞赞
    if (lastSelectState) {
        NSInteger lastSelectStateInt = [lastSelectState integerValue];
        if ((lastSelectStateInt == stateRefusal && disDay >= ShowRefusalDay) || (lastSelectStateInt == stateComplaints && disDay >= ShowComplaintsDay) || (lastSelectStateInt == statePraise && disDay >= ShowPraiseDay)) {
            //保存时间
            [self alertUserCommentView];
        }
    } else {
        if (disDay >= ShowRefusalDay) {
            [self alertUserCommentView];
        }
    }

}

- (void)alertUserCommentView {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"😭残忍拒绝" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [userDefault setInteger:stateRefusal forKey:LastSelectState];
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"😄好评赞赏" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [userDefault setInteger:statePraise forKey:LastSelectState];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPSTORE_UEL]];
//        [self evaluate];
    }];
    
    UIAlertAction *showAction = [UIAlertAction actionWithTitle:@"😓我要吐槽" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [userDefault setInteger:stateComplaints forKey:LastSelectState];
        //跳转到AppStore
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPSTORE_UEL]];
//        [self evaluate];
    }];
    
    
    [alertController addAction:refuseAction];
    [alertController addAction:okAction];
    [alertController addAction:showAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

//系统内部进入AppStore
- (void)evaluate {
    SKStoreProductViewController *storeProdutVC = [[SKStoreProductViewController alloc]init];
    storeProdutVC.delegate = self;
    [storeProdutVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:@"1142134162"} completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
        } else {
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:storeProdutVC animated:YES completion:nil];
        }
    }];
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSString *)title {
    return _title == nil ? @"致用户的一封信":_title;
}

- (NSString *)message {
    return _message == nil ? @"有了您的支持才能更好的为您服务，提供更加优质的，更加适合您的App，当然您也可以直接反馈问题给到我们":_message;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}
@end
