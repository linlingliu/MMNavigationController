//
//  MMNavigationController.h
//  MiaoMiaoDai
//
//  Created by LX on 2018/4/16.
//  Copyright © 2018年 iSong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMWrapViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController *rootViewController;

+ (MMWrapViewController *)wrapWithViewController:(UIViewController *)viewController;

@end


@interface MMNavigationController : UINavigationController

@property (nonatomic, strong) UIImage *backButtonImage;
@property (nonatomic, strong ,readonly) NSArray *mm_viewControllers;

- (void)insertViewController:(UIViewController *)viewController index:(NSInteger)index;
- (void)removeViewController:(NSInteger)index;

@end
