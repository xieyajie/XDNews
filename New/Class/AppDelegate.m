//
//  AppDelegate.m
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "XDTabBarController.h"
#import "XDInformationViewController.h"
#import "XDHotPictureViewController.h"
#import "XDSpecialTopicViewController.h"
#import "XDFavoriteViewController.h"
#import "XDSettingViewController.h"
#import "XDDataCenter.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    XDInformationViewController *newInfoViewController = [[XDInformationViewController alloc] initWithNibName: @"XDInformationViewController" bundle: nil];
    newInfoViewController.title = @"资讯";
    newInfoViewController.tabBarItem.image = [UIImage imageNamed:@"infomation.png"];
    UINavigationController *infoNav = [[UINavigationController alloc] initWithRootViewController: newInfoViewController];
    infoNav.view.frame = CGRectMake(0, 0, 320, 460);
    infoNav.navigationBar.hidden = YES;

    XDHotPictureViewController *hotPicViewController = [[XDHotPictureViewController alloc] init];
    hotPicViewController.title = @"热图";
    hotPicViewController.tabBarItem.image = [UIImage imageNamed: @"hotPic.png"];
    UINavigationController *pictureNav = [[UINavigationController alloc] initWithRootViewController: hotPicViewController];
    pictureNav.view.frame = CGRectMake(0, 0, 320, 460);
    pictureNav.navigationBar.hidden = YES;
    
    XDSpecialTopicViewController *topicViewController = [[XDSpecialTopicViewController alloc] init];
    topicViewController.title = @"分类";
    topicViewController.tabBarItem.image = [UIImage imageNamed: @"topic.png"];
    UINavigationController *topicNav = [[UINavigationController alloc] initWithRootViewController: topicViewController];
    topicNav.view.frame = CGRectMake(0, 0, 320, 460);
    topicNav.navigationBar.hidden = YES;
    
    XDFavoriteViewController *favoriteViewController = [[XDFavoriteViewController alloc] init];
    favoriteViewController.title = @"收藏";
    favoriteViewController.tabBarItem.image = [UIImage imageNamed: @"favorite.png"];
    UINavigationController *favNav = [[UINavigationController alloc] initWithRootViewController: favoriteViewController];
    favNav.view.frame = CGRectMake(0, 0, 320, 460);
    favNav.navigationBar.hidden = YES;
    
    XDSettingViewController *setting = [[XDSettingViewController alloc] init];
    setting.title = @"设置";
    setting.tabBarItem.image = [UIImage imageNamed: @"more.png"];
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController: setting];
    settingNav.navigationBar.hidden = YES;
    
    self.tabBarController = [[[XDTabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:infoNav, pictureNav, topicNav, favNav, settingNav, nil];
    [self.tabBarController.view addSubview: infoNav.view];

    [newInfoViewController release];
    [infoNav release];
    
    [hotPicViewController release];
    [pictureNav release];
    
    [topicViewController release];
    [topicNav release];
    
    [favoriteViewController release];
    [favNav release];
    
    [setting release];
    [settingNav release];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
    
    return YES;
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[XDDataCenter sharedCenter] cacheData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
