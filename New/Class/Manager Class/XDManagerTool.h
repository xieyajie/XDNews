//
//  XDManagerTool.h
//  New
//
//  Created by yajie xie on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h" 

@class XDInformationViewController; 

@interface XDManagerTool : NSObject
<CLLocationManagerDelegate, UIWebViewDelegate, 
MFMailComposeViewControllerDelegate>
{
    //位置、天气相关
    CLLocationManager *locationManager;
    XDInformationViewController *cityCaller;
    NSString *cityFinishMethod;
    XDInformationViewController *weatherCaller;
    NSString *weatherFinishMethod;
    NSString *fullCityName;
    NSString *simpleCityName;
    NSString *weather;
}

+ (XDManagerTool *)Instance;

//判断是否有网
+ (BOOL)connectedToNetwork;

//获取当前所在城市
- (void)getCityWithCaller: (id)caller finishCallMethod: (NSString *)aMethodName;

//获取当前城市的天气
- (void)getWeatherWithCaller: (id)caller finishCallMethod: (NSString *)methodName;

+ (NSString *)getWebViewHtmlStyle;

//获取所有收藏
+ (NSArray *)getAllInfo;

//判断新闻是否已经收藏
+ (BOOL)judgeNewsId: (NSNumber *)newsId;

//删除收藏的新闻
+ (BOOL)deleteFavoriteNewsById: (NSNumber *)newsId;

//将新闻添加到我的收藏
+ (BOOL)addNewsToFavorite: (NSDictionary *)newsInfo content: (NSString *)newsContent date: (NSString *)date;

//分享弹出框
+ (UIView *)initSharePopView: (UIViewController *)viewController;

//邮件相关
- (void)emailInViewController: (UIViewController *)viewController title: (NSString *)title body: (NSString *)body isHtml: (BOOL)isHtml;
- (void)emailInViewController: (UIViewController *)viewController imgUrl: (NSString *)imgUrl title: (NSString *)title body: (NSString *)body;

@end
