#系统内部进入AppStore
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

SKStoreProductParameterITunesItemIdentifier:@"输入跳转AppStore的id"

#跳转AppStore评论 
//#define APPSTORE_UEL @"iTunesid地址"
//时间可以自行修改
//#define ShowRefusalDay 0
//#define ShowComplaintsDay 8
//#define ShowPraiseDay 16

[[QPushToAppStore sharePushToAppStpre] showGotoAppStore]; 即可

#检测版本更新
// 应用已经发布到APP Store后才会在Itunes上有应用的链接
// 所以版本检测必须是已经发布过才能做
// 在真正实现功能时，需要替换成真正的链接
//#define kAppStoreLink  @""
//#define kItunsLink @""
[[KaneVersionManager shareInstance]checkVersion:1]; //如果type！=1  版本不更新就不提示 

