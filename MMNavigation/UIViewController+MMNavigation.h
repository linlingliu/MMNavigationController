//
//  UIViewController+MMNavigation.h
//  MiaoMiaoDai
//
//  Created by LX on 2018/4/16.
//  Copyright © 2018年 iSong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMNavigationController.h"

@interface UIViewController (MMNavigation)

@property (nonatomic, assign) BOOL mm_leftGestureEnabled;      //右滑返回
@property (nonatomic, assign) BOOL mm_isDefaultStatusBar;      //默认状态栏
@property (nonatomic, strong) MMNavigationController *mm_navigationController;

- (BOOL)didPopClick;

@end
