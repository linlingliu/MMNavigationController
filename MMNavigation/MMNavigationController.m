//
//  MMNavigationController.m
//  MiaoMiaoDai
//
//  Created by LX on 2018/4/16.
//  Copyright © 2018年 iSong. All rights reserved.
//

#import "MMNavigationController.h"
#import "UIViewController+MMNavigation.h"

#pragma mark -- MMWrapNavigationController

@interface MMWrapNavigationController : UINavigationController

@end

@implementation MMWrapNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [self.navigationController popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self.navigationController popToRootViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    MMNavigationController *_navigationController=viewController.mm_navigationController;
    NSInteger index=[_navigationController.mm_viewControllers indexOfObject:viewController];
    return [self.navigationController popToViewController:_navigationController.viewControllers[index] animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.mm_navigationController=(MMNavigationController *)self.navigationController;
    
    if(viewController.mm_isDefaultStatusBar){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    if (self.viewControllers.count >0) {
        viewController.hidesBottomBarWhenPushed=YES;
    }
    UIImage *backButtonImage = viewController.mm_navigationController.backButtonImage;
    if (!backButtonImage) {
       backButtonImage = [[UIImage imageNamed:@"backImage"]imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    }
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(tapBackButton)];
    [self.navigationController pushViewController:[MMWrapViewController wrapWithViewController:viewController] animated:animated];
}

- (void)tapBackButton
{
    MMNavigationController *_navigationController = (MMNavigationController *)self.navigationController;
    NSArray *_controllers = _navigationController.mm_viewControllers;
    UIViewController *_controller = _controllers[_controllers.count-1];
    if(![_controller didPopClick]){
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self.navigationController dismissViewControllerAnimated:flag completion:completion];
    self.viewControllers.firstObject.mm_navigationController = nil;
}

@end

#pragma mark -- MMWrapViewController

static NSValue *mm_tabBarRectValue;

@implementation MMWrapViewController

+ (MMWrapViewController *)wrapWithViewController:(UIViewController *)viewController
{
    MMWrapNavigationController *wrapNavController = [[MMWrapNavigationController alloc] init];
    wrapNavController.view.backgroundColor = [UIColor whiteColor];
    wrapNavController.viewControllers = @[viewController];
    
    MMWrapViewController *wrapViewController = [[MMWrapViewController alloc] init];
    wrapViewController.view.backgroundColor = [UIColor whiteColor];
    [wrapViewController.view addSubview:wrapNavController.view];
    [wrapViewController addChildViewController:wrapNavController];
    
    return wrapViewController;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(self.tabBarController && !mm_tabBarRectValue) {
        mm_tabBarRectValue = [NSValue valueWithCGRect:self.tabBarController.tabBar.frame];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.tabBarController && [self rootViewController].hidesBottomBarWhenPushed) {
        self.tabBarController.tabBar.frame = CGRectZero;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    if(self.tabBarController && !self.tabBarController.tabBar.hidden && mm_tabBarRectValue) {
        self.tabBarController.tabBar.frame = mm_tabBarRectValue.CGRectValue;
    }
}


- (BOOL)mm_leftGestureEnabled
{
    return [self rootViewController].mm_leftGestureEnabled;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return [self rootViewController].hidesBottomBarWhenPushed;
}

- (UITabBarItem *)tabBarItem
{
    return [self rootViewController].tabBarItem;
}

- (NSString *)title
{
    return [self rootViewController].title;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return [self rootViewController];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return [self rootViewController];
}

- (UIViewController *)rootViewController
{
    MMWrapNavigationController *wrapNavController = self.childViewControllers.firstObject;
    return wrapNavController.viewControllers.firstObject;
}

- (BOOL)didPopClick
{
    return [[self rootViewController] didPopClick];
}

@end



@interface MMNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>
{
    UIPanGestureRecognizer     *_leftPanGesture;
    id                         _leftPanGestureDelegate;
}
@end

@implementation MMNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self=[super init]) {
        rootViewController.mm_navigationController=self;
        rootViewController.automaticallyAdjustsScrollViewInsets=NO;
        self.viewControllers=@[[MMWrapViewController wrapWithViewController:rootViewController]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        self.viewControllers.firstObject.mm_navigationController=self;
        self.viewControllers=@[[MMWrapViewController wrapWithViewController:self.viewControllers.firstObject]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setNavigationBarHidden:YES];
    self.delegate=self;
    _leftPanGestureDelegate =self.interactivePopGestureRecognizer.delegate;
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    _leftPanGesture=[[UIPanGestureRecognizer alloc]initWithTarget:_leftPanGestureDelegate action:action];
    _leftPanGesture.maximumNumberOfTouches=1;
}

#pragma mark -- Method

- (void)insertViewController:(UIViewController *)viewController index:(NSInteger)index
{
    if(index<self.viewControllers.count){
        NSMutableArray *_controllers = @[].mutableCopy;
        [_controllers addObjectsFromArray:self.viewControllers];
        [_controllers insertObject:[MMWrapViewController wrapWithViewController:viewController] atIndex:index];
        self.viewControllers = _controllers;
    }
}

- (void)removeViewController:(NSInteger)index
{
    NSMutableArray *_controllers = @[].mutableCopy;
    [_controllers addObjectsFromArray:self.viewControllers];
    [_controllers removeObjectAtIndex:index];
    self.viewControllers = _controllers;
}

- (NSArray *)mm_viewControllers
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (MMWrapViewController *wrapViewController in self.viewControllers) {
        [viewControllers addObject:wrapViewController.rootViewController];
    }
    return viewControllers.copy;
}

#pragma mark - UIGestureRecognizerDelegate

//修复有水平方向滚动的  ScrollView  时边缘返回手势失效的问题
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    
    if (viewController.mm_leftGestureEnabled) {
        if (isRootVC) {
            [self.view removeGestureRecognizer:_leftPanGesture];
        } else {
            [self.view addGestureRecognizer:_leftPanGesture];
        }
        self.interactivePopGestureRecognizer.delegate = _leftPanGestureDelegate;
        self.interactivePopGestureRecognizer.enabled = YES;
    } else {
        [self.view removeGestureRecognizer:_leftPanGesture];
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

@end
