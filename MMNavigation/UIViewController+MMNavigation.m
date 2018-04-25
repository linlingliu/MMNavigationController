//
//  UIViewController+MMNavigation.m
//  MiaoMiaoDai
//
//  Created by LX on 2018/4/16.
//  Copyright © 2018年 iSong. All rights reserved.
//

#import "UIViewController+MMNavigation.h"
#import <objc/runtime.h>

@implementation UIViewController (MMNavigation)

- (void)setMm_leftGestureEnabled:(BOOL)mm_leftGestureEnabled
{
    objc_setAssociatedObject(self, @selector(mm_leftGestureEnabled), @(mm_leftGestureEnabled), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)mm_leftGestureEnabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMm_isDefaultStatusBar:(BOOL)mm_isDefaultStatusBar
{
    objc_setAssociatedObject(self, @selector(mm_isDefaultStatusBar), @(mm_isDefaultStatusBar), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)mm_isDefaultStatusBar
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setMm_navigationController:(MMNavigationController *)mm_navigationController
{
    objc_setAssociatedObject(self, @selector(mm_navigationController), mm_navigationController, OBJC_ASSOCIATION_RETAIN);
}

- (MMNavigationController *)mm_navigationController
{
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)didPopClick
{
    return YES;
}

@end
