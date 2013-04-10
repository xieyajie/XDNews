//
//  XDFavoriteDetailViewController.m
//  New
//
//  Created by yajie xie on 12-9-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDFavoriteDetailViewController.h"
#import "XDForwardToBlogViewController.h"
#import "XDTabBarController.h"
#import "XDManagerTool.h"
#import "LocalDefine.h"

@interface XDFavoriteDetailViewController ()

- (void)back;

- (void)loadNewsDetailInfo: (NSString *)contentHtml;

- (void)shareNew;

- (void)prevNew;

- (void)nextNew;

@end

@implementation XDFavoriteDetailViewController

@synthesize detailDataSource;
@synthesize currentNum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        detailDataSource = [[NSMutableArray alloc] init];
        contentHtml = [[NSString alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 320, 460);
    self.view.backgroundColor = [UIColor colorWithRed: 240 / 255.0 green: 239 / 255.0 blue: 235 / 255.0 alpha:1.0];
    
    UIButton *backBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [backBtn setImage: [UIImage imageNamed:@"preview.png"] forState: UIControlStateNormal];
    [backBtn addTarget: self action:@selector(back) forControlEvents: UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(10, 5, 30, 30);
    backBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview: backBtn];
    
    shareBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(320 - 45, 5, 35, 35);
    [shareBtn setImage: [UIImage imageNamed: @"favShare.png"] forState: UIControlStateNormal];
    [shareBtn addTarget: self action: @selector(shareNew) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: shareBtn];
    
    prevBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(320 - 135, 5, 35, 35);
    [prevBtn setImage: [UIImage imageNamed: @"favPrev.png"] forState: UIControlStateNormal];
    [prevBtn addTarget: self action: @selector(prevNew) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: prevBtn];
    
    nextBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(320 - 90, 5, 35, 35);
    [nextBtn setImage: [UIImage imageNamed: @"favNext.png"] forState: UIControlStateNormal];
    [nextBtn addTarget: self action: @selector(nextNew) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: nextBtn];

    contentView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 44, 320, 460 - 44)];
    [contentView setBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:239 / 255.0 blue:235 / 255.0 alpha:1.0]];
    [contentView setOpaque:NO]; 
    contentView.scrollView.bounces = NO;
    contentView.delegate = self;
    [self.view addSubview: contentView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    contentView.hidden = YES;
    shareBtn.enabled = NO;
    prevBtn.enabled = NO;
    nextBtn.enabled = NO;
    [self loadNewsDetailInfo: [[detailDataSource objectAtIndex: currentNum] valueForKey: KFAVORITENEWSCONTENT]];
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

#pragma mark -
#pragma mark UIWebView Delegate 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    contentView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    shareBtn.enabled = YES;
    prevBtn.enabled = YES;
    nextBtn.enabled = YES;
    [MBProgressHUD hideHUDForView: self.view animated: YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: @"错误" message: @"内容加载失败！" delegate: self cancelButtonTitle: @"重新加载" otherButtonTitles: @"稍后再试", nil];
    [errorAlert show];
    [errorAlert release];
}

#pragma mark - CMPopTipViewDelegate

- (void)shareByMail: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
    
    [[XDManagerTool Instance] emailInViewController: self title: [[detailDataSource objectAtIndex: currentNum] valueForKey: KFAVORITENEWSTITLE] body: contentHtml isHtml: YES];
}

- (void)shareByTencentBlog: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
    
    if ([XDManagerTool connectedToNetwork])
    {
        NSString *shareContent = [[NSString alloc] initWithFormat: @"%@%@", [[detailDataSource objectAtIndex: currentNum] objectForKey: KFAVORITENEWSTITLE], [[detailDataSource objectAtIndex: currentNum] objectForKey: KFAVORITENEWSWEBURL]];
        [[XDForwardToBlogViewController shareController] shareScriptByTencentBlog: self shareContent: shareContent];
        [shareContent release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: @"当前网络不给力，请稍后再试！" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)shareBySinaBlog: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
    
    if ([XDManagerTool connectedToNetwork])
    {
        NSString *shareContent = [[NSString alloc] initWithFormat: @"%@%@", [[detailDataSource objectAtIndex: currentNum] objectForKey: KFAVORITENEWSTITLE], [[detailDataSource objectAtIndex: currentNum] objectForKey: KFAVORITENEWSWEBURL]];
        [[XDForwardToBlogViewController shareController] shareBySinaBlog: self shareContent: shareContent shareImage: nil];
        [shareContent release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: @"当前网络不给力，请稍后再试！" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
    }
}



#pragma mark - private mothod

- (void)back
{
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = NO;
    
    [self.navigationController popViewControllerAnimated: YES];
}


- (void)loadNewsDetailInfo: (NSString *)content
{
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    if (contentHtml != nil) 
    {
        [contentHtml release];
    }
    contentHtml = [[NSString alloc] initWithFormat:@"<body style='background-color:#f0efeb'>%@<div id='new_title'>%@</div><div id='new_outline'>%@</div><hr/><div id='new_body'>%@</div></body>",[XDManagerTool getWebViewHtmlStyle], [[detailDataSource objectAtIndex: currentNum] valueForKey: KFAVORITENEWSTITLE],[[detailDataSource objectAtIndex: currentNum] valueForKey: KFAVORITENEWSDATE], content];
    [contentView loadHTMLString: contentHtml baseURL: nil];
}

- (void)shareNew
{
    if (popShare == nil)
    {
        popShare = [[CMPopTipView alloc] initWithCustomView: [XDManagerTool initSharePopView: self]];
        popShare.delegate = self;
        popShare.backgroundColor = [UIColor lightGrayColor];
    }
    
    if (!popShare.isPop) 
    {
        popShare.shandowView.frame = self.view.frame;
        [self.view addSubview: popShare.shandowView];
        [popShare presentPointingAtView: shareBtn inView: self.view animated: YES];
        [self.view bringSubviewToFront: popShare];
    }
    else 
    {
        [popShare dismissAnimated:YES];
    }
}

- (void)prevNew
{
    if (currentNum == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"警告" message: @"已经是第一篇了" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        
        [alert show];
        [alert release];
        
        return ;
    }
    
    currentNum--;
    [self loadNewsDetailInfo: [[detailDataSource objectAtIndex: currentNum] valueForKey: KFAVORITENEWSCONTENT]];
}

- (void)nextNew
{
    if (currentNum == [detailDataSource count] - 1) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"警告" message: @"已经是最后一篇了" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        
        [alert show];
        [alert release];
        
        return ;
    }
    
    currentNum++;
    [self loadNewsDetailInfo: [[detailDataSource objectAtIndex: currentNum] valueForKey: KFAVORITENEWSCONTENT]];
}


@end
