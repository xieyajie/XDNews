//
//  XDManagerTool.m
//  New
//
//  Created by yajie xie on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#import "XDManagerTool.h"
#import "XDInformationViewController.h"
#import "LocalDefine.h"
#import "XDDataCenter.h"

static XDManagerTool * instance = nil;

@interface XDManagerTool()

//回调函数
-(void)callWithObject:(id)sender selectorName:(NSString *)methodName returnResult: (id)result;

@end

static NSString *HTML_Style = @"<style>#new_title {color: #000000; margin-bottom: 10px; font-weight:bold; font-size:titleFontSizepx;}#new_title img{vertical-align:middle;margin-right:6px;}#new_title a{color:#0D6DA8;}#new_outline {color: #707070; font-size: dateFontSizepx;}#new_outline a{color:#0D6DA8;}new_body img {max-width: 300px;}#new_body {font-size:contentFontSizepx;max-width:300px;line-height:24px;} #new_body table{max-width:300px;}#new_body pre { font-size:9pt;font-family:Courier New,Arial;border:1px solid #ddd;border-left:5px solid #6CE26C;background:#f6f6f6;padding:5px;}</style>";

static NSString *kTitleFontSize = @"titleFontSize";
static NSString *kDateFontSize = @"dateFontSize";
static NSString *kContentFontSize = @"contentFontSize";

#define kWeatherServiceURLStr @"http://webservice.webxml.com.cn/WebServices/WeatherWebService.asmx/getWeatherbyCityName?theCityName="

@implementation XDManagerTool

#pragma 单例模式定义
+ (XDManagerTool *)Instance
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+ (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark - CLLocationManager delegate
//定位成功调用
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if ([placemarks count] > 0) 
         {
             CLPlacemark *placemark = [placemarks objectAtIndex: 0];
             
             fullCityName = placemark.locality;
             if ([fullCityName hasSuffix:@"市"]) 
             {
                 simpleCityName = [fullCityName substringToIndex: fullCityName.length-1];
             }
             [self callWithObject: cityCaller selectorName: cityFinishMethod returnResult: simpleCityName];
         }
     }];
    
    [geocoder release];
    
    [locationManager stopUpdatingLocation];
}

//定位出错时被调
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"获取经纬度失败，失败原因：%@", [error description]);
    
    [locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark MFMailComposeViewController Delegate 
-(void)messageShow:(NSString *)msg
{
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *) error{
    
    switch (result) { 
        case MFMailComposeResultCancelled: 
            [self messageShow:@"邮件已取消！"];
            break; 
        case MFMailComposeResultSaved: 
            [self messageShow:@"邮件已保存！"];
            break; 
        case MFMailComposeResultSent: 
            [self messageShow:@"邮件发送成功！"];
            break; 
        case MFMailComposeResultFailed: 
            [self messageShow:@"邮件发送失敗！"];
            break; 
    } 
    [controller dismissModalViewControllerAnimated: YES]; 
    
}


#pragma mark - custom methods

-(void)callWithObject:(id)sender selectorName:(NSString *)methodName returnResult: (id)result
{
    SEL method = NSSelectorFromString(methodName);
    
    if ([sender respondsToSelector: method]) 
    {
        [sender performSelector: method withObject: result];
    }
}

#pragma mark - 获得地址
- (void)getCityWithCaller: (id)caller finishCallMethod: (NSString *)aMethodName
{
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"您关闭了的定位功能，将无法收到位置信息，建议您到系统设置打开定位功能!");
    }
    else 
    {
        cityCaller = caller;
        cityFinishMethod = aMethodName;
        
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
}

#pragma mark - 获得天气
- (void)getWeatherWithCaller: (id)caller finishCallMethod: (NSString *)methodName
{
    weatherCaller = caller;
    weatherFinishMethod = methodName;
    
    NSString *weatherRequestUrlStr = [NSString stringWithFormat:@"%@%@",kWeatherServiceURLStr,[simpleCityName stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	NSData *weatherReponseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:weatherRequestUrlStr]];
    NSString *str = [[NSString alloc] initWithData: weatherReponseData encoding:NSUTF8StringEncoding];
    
    NSArray *array = [str componentsSeparatedByString:@"<string>"];
    NSString *weatherStr = @"";
    if ([array count] > 6) 
    {
        weatherStr = [array objectAtIndex: 6];
        NSRange range = [weatherStr rangeOfString: @"</string>"];
        NSRange subRange;
        subRange.location = 0;
        subRange.length = range.location;
        weatherStr = [weatherStr substringWithRange: subRange];
    }
    
    [str release];
    
    [self callWithObject: weatherCaller selectorName: weatherFinishMethod returnResult: weatherStr];
}

#pragma mark - 我的收藏相关

+ (NSString *)getWebViewHtmlStyle
{
    NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent: KSETTINGPLIST];
    NSDictionary *settingDic = [[[NSDictionary alloc] initWithContentsOfFile: plistPath] autorelease];
    
    int fontSize = [[settingDic objectForKey: KFONTSIZEKEY] intValue];
    NSString *str1 = nil;
    NSString *str2 = nil;
    NSString *str3 = nil;
    switch (fontSize) {
        case 0:
            str1 = [HTML_Style stringByReplacingOccurrencesOfString: kTitleFontSize withString: KTITLEFONTSIZEMIN];
            str2 = [str1 stringByReplacingOccurrencesOfString: kDateFontSize withString: KDATEFONTSIZEMIN];
            str3 = [str2 stringByReplacingOccurrencesOfString: kContentFontSize withString: KCONTENTFONTSIZEMIN];
            break;
        case 1:
            str1 = [HTML_Style stringByReplacingOccurrencesOfString: kTitleFontSize withString: KTITLEFONTSIZEMID];
            str2 = [str1 stringByReplacingOccurrencesOfString: kDateFontSize withString: KDATEFONTSIZEMID];
            str3 = [str2 stringByReplacingOccurrencesOfString: kContentFontSize withString: KCONTENTFONTSIZEMID];
            break;
        case 2:
            str1 = [HTML_Style stringByReplacingOccurrencesOfString: kTitleFontSize withString: KTITLEFONTSIZEMAX];
            str2 = [str1 stringByReplacingOccurrencesOfString: kDateFontSize withString: KDATEFONTSIZEMAX];
            str3 = [str2 stringByReplacingOccurrencesOfString: kContentFontSize withString: KCONTENTFONTSIZEMAX];
            break;
            
        default:
            break;
    }
    
    return str3;
}

//获取所有收藏
+ (NSArray *)getAllInfo
{
    NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent: KFAVORITENEWSPLIST];
    NSDictionary *favoriteNewDic = [[[NSDictionary alloc] initWithContentsOfFile: plistPath] autorelease];
    return [favoriteNewDic allValues];
}

//判断新闻是否已经收藏
+ (BOOL)judgeNewsId: (NSNumber *)newsId
{
    NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent: KFAVORITENEWSPLIST];
    NSDictionary *favoriteNewDic = [[NSDictionary alloc] initWithContentsOfFile: plistPath];
    NSArray *newsIdArray = [favoriteNewDic allKeys];
    
    for (NSString *objectId in newsIdArray)
    {
        if ([objectId intValue] == [newsId intValue]) 
        {
            [favoriteNewDic release];
            
            return YES;
        }
    }
    
    [favoriteNewDic release];
    
    return NO;
}

//删除收藏的新闻
+ (BOOL)deleteFavoriteNewsById: (NSNumber *)newsId
{
    NSString *strId = [newsId stringValue];
    if (strId != nil && strId != @"")
    {
        NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent: KFAVORITENEWSPLIST];
        NSMutableDictionary *favoriteNewDic = [[NSMutableDictionary alloc] initWithContentsOfFile: plistPath];
        
        [favoriteNewDic removeObjectForKey: strId];
        BOOL result = [favoriteNewDic writeToFile: plistPath atomically: YES];
        [favoriteNewDic release];
        
        return result;
    }
    else 
    {
        return NO;
    }
}

//将新闻添加到我的收藏
+ (BOOL)addNewsToFavorite: (NSDictionary *)newsInfo content: (NSString *)newsContent date: (NSString *)date
{
    NSString *newsId = [[NSString alloc] initWithString: [[newsInfo objectForKey: KINFOCELLID] stringValue]];
    
    if (newsId != nil && newsId != @"")
    {
        NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent: KFAVORITENEWSPLIST];
        NSString *imgPath = [NSHomeDirectory() stringByAppendingPathComponent: KFAVORITENEWSIMGCACHE];
        NSFileManager *fileManage = [NSFileManager defaultManager];
        if (![fileManage fileExistsAtPath: imgPath]) 
        {
            [fileManage createDirectoryAtPath: imgPath withIntermediateDirectories: YES attributes:nil error:nil]; 
        }
        if (![fileManage fileExistsAtPath: plistPath]) 
        {
            [fileManage createFileAtPath: plistPath contents: nil attributes: nil]; 
        }
        
        NSMutableDictionary *favoriteNewDic = [[NSMutableDictionary alloc] initWithContentsOfFile: plistPath];
        if (favoriteNewDic == nil) 
        {
            favoriteNewDic = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *newsDic = [[NSMutableDictionary alloc] init];
        [newsDic setObject: [newsInfo objectForKey: KINFOCELLID] forKey: KFAVORITENEWSID];
        [newsDic setObject: [newsInfo objectForKey: KINFOCELLWEBURL] forKey: KFAVORITENEWSWEBURL];
        [newsDic setObject: [newsInfo objectForKey: KINFOCELLPREVIEW] forKey: KFAVORITENEWSBRIEF];
        [newsDic setObject: [newsInfo objectForKey: KINFOCELLTITLE] forKey: KFAVORITENEWSTITLE];
        [newsDic setObject: date forKey: KFAVORITENEWSDATE];
        [newsDic setObject: newsContent forKey: KFAVORITENEWSCONTENT];
        
        NSString *imgOldPath = [[XDDataCenter sharedCenter] getCacheImagePath: [newsInfo objectForKey: KINFOCELLIMG]];
        if (imgOldPath && ![imgOldPath isEqualToString: @""])
        {
            NSString *imgName = [imgOldPath lastPathComponent];
            NSString *imgNewPath = [[NSString alloc] initWithFormat: @"%@/%@", imgPath, imgName];
            [fileManage copyItemAtPath: imgOldPath toPath: imgNewPath error: nil];
            [newsDic setObject: imgNewPath forKey: KFAVORITENEWSIMG];
            [imgNewPath release];
        }
        else{
            [newsDic setObject: @"" forKey: KFAVORITENEWSIMG];
        }
        
        
        [favoriteNewDic setObject: newsDic forKey: newsId];
        [newsId release];
        
        BOOL result = [favoriteNewDic writeToFile: plistPath atomically: YES];
        
        [favoriteNewDic release];
        [newsDic release];
        
        return result;
    }
    else 
    {
        [newsId release];
        return NO;
    }
}

#pragma mark - 分享弹出框

+ (UIView *)initSharePopView: (UIViewController *)viewController
{
    UIView *view = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 170, 50)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *tencentBt = [UIButton buttonWithType: UIButtonTypeCustom];
    [tencentBt setImage: [UIImage imageNamed: @"tencentBlog.png"] forState: UIControlStateNormal];
    [tencentBt addTarget: viewController action: @selector(shareByTencentBlog:) forControlEvents: UIControlEventTouchUpInside];
    tencentBt.frame = CGRectMake(0, 0, 50, 50);
    [view addSubview: tencentBt];
    
    UIButton *sinaBt = [UIButton buttonWithType: UIButtonTypeCustom];
    [sinaBt setImage: [UIImage imageNamed: @"sinaBlog.png"] forState: UIControlStateNormal];
    [sinaBt addTarget: viewController action: @selector(shareBySinaBlog:) forControlEvents: UIControlEventTouchUpInside];
    sinaBt.frame = CGRectMake(60, 0, 50, 50);
    [view addSubview: sinaBt];
    
    UIButton *mailBt = [UIButton buttonWithType: UIButtonTypeCustom];
    [mailBt setImage: [UIImage imageNamed: @"email.png"] forState: UIControlStateNormal];
    [mailBt addTarget: viewController action: @selector(shareByMail:) forControlEvents: UIControlEventTouchUpInside];
    mailBt.frame = CGRectMake(120, 0, 50, 50);
    [view addSubview: mailBt];
    
    return view;
}

#pragma mark - 邮件相关
//1判断是否能发邮件（不能提示没有网络）2判断是否有选中的文件（没有提示）3压缩文件，同时显示waiting 4waiting消失，显示发送邮件的界面 5界面消失，删除文件
- (void)emailInViewController: (UIViewController *)viewController title: (NSString *)title body: (NSString *)body isHtml: (BOOL)isHtml
{
    if ([MFMailComposeViewController canSendMail]) 
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self; 
        [picker setSubject: title];
        [picker setMessageBody: body isHTML: isHtml];
        [viewController presentModalViewController:picker animated:YES];
        [picker release];
	}
	else 
    {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"警告" message: @"网络未连接" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
	}
}

- (void)emailInViewController: (UIViewController *)viewController imgUrl: (NSString *)imgUrl title: (NSString *)title body: (NSString *)body
{
    if ([MFMailComposeViewController canSendMail]) 
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self; 
        [picker setSubject: title];
        
        NSData *imgData = [[NSData alloc] initWithContentsOfFile: imgUrl];
        NSString *type = [[NSString alloc] initWithFormat: @"%@%@", @"image/", [imgUrl pathExtension]];
        [picker addAttachmentData: imgData mimeType: type fileName: [imgUrl lastPathComponent]];
        [type release];
        [imgData release];
        
        [picker setMessageBody: body isHTML: NO];
        [viewController presentModalViewController:picker animated:YES];
        [picker release];
	}
	else 
    {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"警告" message: @"网络未连接" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
	}
}


@end