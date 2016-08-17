//
//  QPushToAppStore.h
//  PushToAppStore
//
//  Created by pactera on 16/8/16.
//  Copyright © 2016年 com.storyboard.pactera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    stateRefusal=1,    // 残忍拒绝
    stateComplaints,    //我要吐槽
    statePraise         //好评
} lastSelectStateEunm;

@interface QPushToAppStore : NSObject
+ (QPushToAppStore*)sharePushToAppStpre;

- (void)showGotoAppStore;
@end
