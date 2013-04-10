//
//  XDTabBarController.h
//  New
//
//  Created by yajie xie on 12-9-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface XDTabBarController : UIViewController//UITabBarController
{
    NSMutableArray *itemButtons;
    int currentSelectedIndex;
    UIView *customTabBarView;
    UIImageView *tabBarBgImgView;
    UIImageView *slideBg;
    
    NSArray *viewControllers;
    UINavigationController *contentNavigation;
}

@property (nonatomic, strong) UIView *customTabBarView;
@property (nonatomic, strong) NSMutableArray *itemButtons;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, strong)  NSArray *viewControllers;

- (void)setControllers: (NSArray *)array;

@end
