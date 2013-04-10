//
//  XDForwardToBlogViewController.m
//  New
//
//  Created by yajie xie on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "XDForwardToBlogViewController.h"
#import "LocalDefine.h"

static XDForwardToBlogViewController *viewController = nil;

@interface XDForwardToBlogViewController ()

- (void)back;

- (void)showSinaBindView: (NSNotification *)notification;

@end

@implementation XDForwardToBlogViewController

@synthesize webView = _webView;
@synthesize shareType = _shareType;
@synthesize shareStyle = _shareStyle;
@synthesize isTencentAuthOK;
@synthesize isSinaBlogAuthOK;

+ (XDForwardToBlogViewController *)shareController
{
    @synchronized(self) {
        if (viewController == nil) {
            viewController = [[self alloc] init];
        }
    }
    return viewController;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        isTencentAuthOK = NO;
        isSinaBlogAuthOK = NO;
        _shareStyle = XDShareStyleDefault;
        _shareType = XDShareTypeInvalid;
        
        _openSdkOauth = [[OpenSdkOauth alloc] initAppKey:[OpenSdkBase getAppKey] appSecret:[OpenSdkBase getAppSecret]];
        
        _wbEngine = [[WBEngine alloc] initWithAppKey: KSINAAPPKEY appSecret: KSINAAPPSECRET];
        _wbEngine.rootViewController = self;
        _wbEngine.delegate = self;
        _wbEngine.redirectURI = @"http://";
        _wbEngine.isUserExclusive = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    UIImageView *topView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, bounds.size.width, KLogoViewHeight)];
    topView.image = [UIImage imageNamed: @"topBar.png"];
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(4, 4);
    topView.layer.shadowOpacity = 1.0;
    topView.layer.shadowRadius = 4.0;
    [self.view addSubview: topView];
    
    CGFloat titleLabelFontSize = 14;
    _titleLabel = [[UILabel alloc] initWithFrame: CGRectMake((bounds.size.width - 100) / 2, 0, 100, topView.frame.size.height)];
    //_titleLabel.text = @"腾讯绑定";
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    _titleLabel.textAlignment = UITextAlignmentCenter;
    [topView addSubview:_titleLabel];
    
    UIButton *closeBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 35, 35)];
    [closeBt setImage: [UIImage imageNamed: @"preview.png"] forState: UIControlStateNormal];
    [closeBt addTarget: self action:@selector(back) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: closeBt];
    [closeBt release];
    [topView release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSinaBindView:) name:KSINASHARELAND object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (_shareType == XDShareTypeTencent)
    {
        NSURL* url = request.URL;
        NSRange start = [[url absoluteString] rangeOfString:oauth2TokenKey];
        
        //如果找到tokenkey,就获取其他key的value值
        if (start.location != NSNotFound)
        {
            NSString *accessToken = [OpenSdkBase getStringFromUrl:[url absoluteString] needle:oauth2TokenKey];
            NSString *openid = [OpenSdkBase getStringFromUrl:[url absoluteString] needle:oauth2OpenidKey];
            NSString *openkey = [OpenSdkBase getStringFromUrl:[url absoluteString] needle:oauth2OpenkeyKey];
            NSString *expireIn = [OpenSdkBase getStringFromUrl:[url absoluteString] needle:oauth2ExpireInKey];
            
            NSDate *expirationDate =nil;
            if (_openSdkOauth.expireIn != nil)
            {
                int expVal = [_openSdkOauth.expireIn intValue];
                if (expVal == 0)
                {
                    expirationDate = [NSDate distantFuture];
                }
                else
                {
                    expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
                }
            }
            
            NSLog(@"token is %@, openid is %@, expireTime is %@", accessToken, openid, expirationDate);
            
            if ((accessToken == (NSString *) [NSNull null]) || (accessToken.length == 0)
                || (openid == (NSString *) [NSNull null]) || (openkey.length == 0)
                || (openkey == (NSString *) [NSNull null]) || (openid.length == 0))
            {
                isTencentAuthOK = NO;
                [_openSdkOauth oauthDidFail:InWebView success:YES netNotWork:NO];
            }
            else
            {
                isTencentAuthOK = YES;
                [_openSdkOauth oauthDidSuccess:accessToken accessSecret:nil openid:openid openkey:openkey expireIn:expireIn];
                [self.navigationController popViewControllerAnimated: YES];
                [self shareToTencentBlog];
            }
            
            return NO;
        }
        else
        {
            start = [[url absoluteString] rangeOfString:@"code="];
            if (start.location != NSNotFound)
            {
                [_openSdkOauth refuseOauth:url];
            }
        }
    }
    else if (_shareType == XDShareTypeSina)
    {
        NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
        
        if (range.location != NSNotFound)
        {
            NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
            
            if ([code isEqualToString:@"21330"])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [_wbEngine.authorize requestAccessTokenWithAuthorizeCode:code];
                
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedToView: _webView animated: YES];
    hud.labelText = @"请稍等...";
}

/*
 * 当网页视图结束加载一个请求后得到通知
 */
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //NSString *url = _webView.request.URL.absoluteString;
    
    [MBProgressHUD hideHUDForView: _webView animated: YES];
}

#pragma mark -
#pragma mark WBEngine Delegate

//login success
- (void)engineDidLogIn:(WBEngine *)engine
{
    isSinaBlogAuthOK = YES;
    [self back];
    [self shareToSinaBlog];
}

//login fail
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    isSinaBlogAuthOK = NO;
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"分享成功" message: nil delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
    [alert show];
    [alert release];
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    NSDictionary *errorInfo = [error userInfo];
    NSInteger error_code = [[errorInfo objectForKey:@"error_code"] intValue];
    if (error_code == 20019)
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"此内容已分享！"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
}

#pragma mark - private

- (void)back
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - 分享到腾讯微博相关
//腾讯微博认证
- (void)shareScriptByTencentBlog: (UIViewController *)viewController shareContent: (NSString *)content
{
    _shareStyle = XDShareStyleDefault;
    _shareType = XDShareTypeTencent;
    
    if (shareContent != nil)
    {
        [shareContent release];
        shareContent = nil;
    }
    shareContent = [[NSString alloc] initWithString: content];
    
    [self shareByTencentBlog: viewController];
}

- (void)shareImageByTencentBlog: (UIViewController *)viewController shareContent: (NSString *)content imageUrl: (NSString *)imgUrl
{
    _shareStyle = XDShareStyleImage;
    _shareType = XDShareTypeTencent;
    
    if (shareImgUrl != nil)
    {
        [shareImgUrl release];
        shareImgUrl = nil;
    }
    shareImgUrl = [[NSString alloc] initWithString: imgUrl];
    
    if (shareContent != nil)
    {
        [shareContent release];
        shareContent = nil;
    }
    shareContent = [[NSString alloc] initWithString: content];
    
    [self shareByTencentBlog: viewController];
}

- (void)shareByTencentBlog: (UIViewController *)viewController
{
    if (isTencentAuthOK)
    {
        [self shareToTencentBlog];
    }
    else
    {
        _titleLabel.text = @"腾讯绑定";
        [viewController.navigationController pushViewController: self animated: YES];
        if (_webView != nil)
        {
            [_webView release];
            [_webView removeFromSuperview];
        }
        CGRect bounds = [[UIScreen mainScreen] applicationFrame];
        _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, bounds.size.width, bounds.size.height - KLogoViewHeight)];
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scalesPageToFit = YES;
        [self.view addSubview: _webView];
        [_openSdkOauth doWebViewAuthorize: _webView];
    }
}

//分享文章到腾讯微博
- (BOOL)shareToTencentBlog
{
    if (_openApi == nil) {
        _openApi = [[OpenApi alloc] initForApi:_openSdkOauth.appKey appSecret:_openSdkOauth.appSecret accessToken:_openSdkOauth.accessToken accessSecret:_openSdkOauth.accessSecret openid:_openSdkOauth.openid oauthType:_openSdkOauth.oauthType];
    }
    if (_shareStyle == XDShareStyleDefault)
    {
        [_openApi publishWeibo: shareContent jing: @"" wei: @"" format:@"json" clientip: KClientIpValue syncflag:@"0"];
    }
    else if (_shareStyle == XDShareStyleImage)
    {
        [_openApi publishWeiboWithImage: shareImgUrl weiboContent: shareContent jing: @"" wei: @"" format: @"json" clientip: KClientIpValue syncflag: @"0"];
    }
    
    return YES;
}

#pragma mark - 分享到新浪微博相关

- (void)showSinaBindView: (NSNotification *)notification
{
//    NSHTTPCookie *cookie;
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (cookie in [storage cookies])
//    {
//        [storage deleteCookie:cookie];
//    }
    
    if (_webView != nil)
    {
        [_webView release];
        [_webView removeFromSuperview];
    }
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, bounds.size.width, bounds.size.height - KLogoViewHeight)];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    [self.view addSubview: _webView];
    
    NSDictionary *urlDic = [notification userInfo];
    NSURLRequest *request =[NSURLRequest requestWithURL: [NSURL URLWithString:[urlDic objectForKey: @"url"]]
                                            cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval: 2.0];
    
    [_webView loadRequest:request];
}

- (void)shareBySinaBlog: (UIViewController *)viewController shareContent: (NSString *)content shareImage: (NSString *)imgUrl
{
    _shareType = XDShareTypeSina;
    if (shareContent != nil)
    {
        [shareContent release];
        shareContent = nil;
    }
    if (content != nil)
    {
        shareContent = [[NSString alloc] initWithString: content];
    }
    
    if (shareImgUrl != nil)
    {
        [shareImgUrl release];
        shareImgUrl = nil;
    }
    if (imgUrl != nil)
    {
        shareImgUrl = [[NSString alloc] initWithString: imgUrl];
    }
    
    [self shareBySinaBlog: viewController];
}

//新浪微博认证
-(void)shareBySinaBlog: (UIViewController *)viewController
{
    _titleLabel.text = @"新浪绑定";
    
    if (!isSinaBlogAuthOK)
    {
        [viewController.navigationController pushViewController: self animated: YES];
        
        [_wbEngine logIn];
    }
    else
    {
        [self shareToSinaBlog];
    }
}

//分享文章到腾讯微博
- (void)shareToSinaBlog
{
    if (shareImgUrl != nil)
    {
        [_wbEngine sendWeiBoWithText: shareContent image: [UIImage imageWithContentsOfFile: shareImgUrl]];
    }
    else {
        [_wbEngine sendWeiBoWithText: shareContent image: nil];
    }
}


@end
