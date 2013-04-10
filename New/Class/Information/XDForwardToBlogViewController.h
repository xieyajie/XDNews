//
//  XDForwardToBlogViewController.h
//  New
//
//  Created by yajie xie on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "OpenSdkOauth.h"
#import "OpenApi.h"
#import "WBEngine.h"

typedef enum {
    XDShareStyleDefault,	// 只分享文字
    XDShareStyleImage		// 分享带图的文字
} XDShareStyle;

typedef enum {
    XDShareTypeInvalid = 0,
    XDShareTypeSina,
    XDShareTypeTencent,
    XDShareTypeRenren
}XDShareType;

@interface XDForwardToBlogViewController : UIViewController
<UIWebViewDelegate, WBEngineDelegate>
{
    UILabel *_titleLabel;
    UIWebView *_webView;
    XDShareType _shareType;
    XDShareStyle _shareStyle;
    
    BOOL isTencentAuthOK;
    OpenSdkOauth *_openSdkOauth;
    OpenApi *_openApi;
    
    BOOL isSinaBlogAuthOK;
    WBEngine *_wbEngine;
    
    NSString *shareContent;
    NSString *shareImgUrl;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) XDShareType shareType;
@property (nonatomic, assign) XDShareStyle shareStyle;
@property (nonatomic, assign) BOOL isTencentAuthOK;
@property (nonatomic, assign) BOOL isSinaBlogAuthOK;

+ (XDForwardToBlogViewController *)shareController;

//分享到腾讯微博相关
- (void)shareByTencentBlog: (UIViewController *)viewController;
- (void)shareScriptByTencentBlog: (UIViewController *)viewController shareContent: (NSString *)content;
- (void)shareImageByTencentBlog: (UIViewController *)viewController shareContent: (NSString *)content imageUrl: (NSString *)imgUrl;
//分享文章到腾讯微博
- (BOOL)shareToTencentBlog;

//分享到新浪微博相关
- (void)shareBySinaBlog: (UIViewController *)viewController;
- (void)shareBySinaBlog: (UIViewController *)viewController shareContent: (NSString *)content shareImage: (NSString *)imgUrl;
//分享文章到腾讯微博
- (void)shareToSinaBlog;

@end
