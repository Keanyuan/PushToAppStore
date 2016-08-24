//
//  KaneVersionManager.m
//  PushToAppStore
//
//  Created by pactera on 16/8/24.
//  Copyright © 2016年 com.storyboard.pactera. All rights reserved.
//

#import "KaneVersionManager.h"

#define kAppStoreLink  @"itms-apps://itunes.apple.com/us/app/lao-you/id1142134162?l=zh&ls=1&mt=8"
#define kItunsLink @"http://itunes.apple.com/cn/lookup?id=1142134162"
#define kRequestTimeOut 60.0

@interface KaneVersionManager() {
    int         _type;
}
@end
@implementation KaneVersionManager

+ (KaneVersionManager *)shareInstance {
    static KaneVersionManager *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareObject) {
            shareObject = [[self alloc]init];
        }
    });
    return shareObject;
}

- (instancetype)init {
    if (self = [super init]) {
        _type = 0;
    }
    return self;
}

- (void)checkVersion:(int)type {
    _type = type;
    [self checkAppStoreVersion];
}

- (void)checkAppStoreVersion {
    if ([NSThread isMainThread]) {
        //使用NSObject类的方法performSelectorInBackground:withObject:来创建一个线程。
        
        [self performSelectorInBackground:@selector(checkAppStoreVersion) withObject:nil];
        return;
    }
    
    @autoreleasepool  {
    //prevent concurrent checks
        static BOOL checking = NO;
        if (checking) return;
        checking = YES;
            
        NSURL *APPUrl = [NSURL URLWithString:kItunsLink];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLRequest *request = [NSURLRequest requestWithURL:APPUrl];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (data && statusCode == 200) {
                error = nil;
                id json = nil;
                if ([NSJSONSerialization class]) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                    json = [dict[@"results"] lastObject];
                    NSLog(@"%s %@",__func__,json);
                } else {
                    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                if (!error) {
                    // 获取到appstore上最新的版本号
                    NSString *latestVersion = [self valueForKey:@"version" inJSON:json];
                    NSString *localVersion = [self appLocalVersion];
                    [self check:latestVersion localVersion:localVersion];
                }
            }
            // finished
            checking = NO;

        }];
        [task resume];
    }
}

- (void)check:(NSString *)latestVersion localVersion:(NSString *)localVersion {
    if ([latestVersion compare:localVersion] == NSOrderedDescending) { // 有新版本
        [self showPromptForUpdate];
    } else if ([latestVersion compare:localVersion options:NSNumericSearch] == NSOrderedSame) {// 已经是最新版本
        if (_type == 1) { // 手动
            [self showMessage];
        }
    }
}

- (void)showMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"当前版本已经是最新版本" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
                [alertController addAction:okAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });

}

- (void)showPromptForUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更新提示" message:@"有新版本发布了，亲，快去更新吧" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"稍后提醒我" style:(UIAlertActionStyleDefault) handler:nil];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即更新" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:kAppStoreLink]];
        }];
        
        [alertController addAction:refuseAction];
        [alertController addAction:okAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

/*!
 * @brief 获取app本地的版本号
 */
- (NSString *)appLocalVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    
    return [version stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
}

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json {
    if ([json isKindOfClass:[NSString class]]) {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound) {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound) {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound) {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""]) {
                        if (valueEnd.location == NSNotFound) {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES) {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0) {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        if (hex != nil) {
                            NSScanner *scanner = [NSScanner scannerWithString:hex];
                            [scanner scanHexInt:&c];
                        }
                        
                        if (c <= 0xffff) {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        } else {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;  
                            unichar high = 0xd800 | (w << 6) | x >> 10;  
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));  
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];  
                        }  
                    }  
                    return value;  
                }  
            }  
        }  
    } else {  
        return json[key];  
    }  
    return nil;  
}

@end
