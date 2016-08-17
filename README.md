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

SKStoreProductParameterITunesItemIdentifier:@"输入跳转AppStore的id"


#define APPSTORE_UEL @"iTunesid地址"





然后直接调用           [[QPushToAppStore sharePushToAppStpre] showGotoAppStore]; 即可