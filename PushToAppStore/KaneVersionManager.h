//
//  KaneVersionManager.h
//  PushToAppStore
//
//  Created by pactera on 16/8/24.
//  Copyright © 2016年 com.storyboard.pactera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KaneVersionManager : NSObject


+ (KaneVersionManager *)shareInstance;

/*
 * 调用此方法来执行版本检测
 * @param type
 */
- (void)checkVersion:(int)type;

@end
