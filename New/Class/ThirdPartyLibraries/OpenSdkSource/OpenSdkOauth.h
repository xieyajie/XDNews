//
//  OpenSdkOauth.h
//  OpenSdkTest
//
//  Created by aine sun on 3/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OpenSdkBase.h"

/*
 * 授权方式，InAuth1－msf授权，InSafari－浏览器登录授权,InWebView-采用webView方式登录授权
 */
typedef enum
{
    InAuth1 = 1,
    InSafari = 2,
    InWebView
}AuthorizeType;

@interface OpenSdkOauth : UIViewController<UINavigationControllerDelegate, UIWebViewDelegate>
{
    IBOutlet UIWebView *_webView;
        
    NSString *_appKey;
    NSString *_appSecret;
    NSString *_redirectURI;
    NSString *_accessToken;
    NSString *_accessSecret;
    NSString *_expireIn;
    NSString *_openid;
    NSString *_openkey;
    uint16_t _oauthType;
}

@property(nonatomic, copy) NSString *appKey;
@property(nonatomic, copy) NSString *appSecret;
@property(nonatomic, copy) NSString *redirectURI;
@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *accessSecret;
@property(nonatomic, copy) NSString *expireIn;
@property(nonatomic, copy) NSString *openid;
@property(nonatomic, copy) NSString *openkey;
@property(nonatomic)uint16_t oauthType;

/*
 * 初始化方法
 */
- (id) initAppKey:appKey appSecret:(NSString *)appSecret;

/*
 * 浏览器登录授权
 */
- (BOOL) doSafariAuthorize:(BOOL)didOpenOtherApp;

/*
 * 采用webView方式登录授权
 */
- (void) doWebViewAuthorize:(UIWebView *)webView;

/*
 * 登录成功后调用，获取OpenSdkOauth各成员变量的值
 */
- (void) oauthDidSuccess:(NSString *)accessToken accessSecret:(NSString *)accessSecret openid:(NSString *)openid openkey:(NSString *)openkey expireIn:(NSString *)expireIn;

/*
 * 授权失败调用，可能由于网络原因或参数值设置原因等
 */
- (void) oauthDidFail:(uint16_t)oauthType success:(BOOL)success netNotWork:(BOOL)netNotWork;

/*
 * webView方式，拒绝授权时调用
 */
- (void) refuseOauth:(NSURL *)url;

@end
