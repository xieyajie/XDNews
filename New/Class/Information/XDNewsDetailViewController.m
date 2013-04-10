//
//  XDNewsDetailViewController.m
//  New
//
//  Created by yajie xie on 12-9-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDNewsDetailViewController.h"
#import "XDTabBarController.h"
#import "XDForwardToBlogViewController.h"
#import "XDDataCenter.h"
#import "XDManagerTool.h"
#import "LocalDefine.h"

@interface XDNewsDetailViewController ()

- (void)setFavoriteButtonImg;

- (void)getNewsDetailInfo: (NSNumber *)newsId;

- (void)favoriteNew;

- (void)showComment;

- (void)shareClick;

- (void)prevNew;

- (void)nextNew;

@end

@implementation XDNewsDetailViewController

@synthesize currentNum;
@synthesize allNewsArray;

@synthesize popShare;

- (void)back
{
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = NO;
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allNewsArray = [[NSMutableArray alloc] init];
        infoDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 320, 460);
    self.view.backgroundColor = [UIColor colorWithRed: 240 / 255.0 green: 239 / 255.0 blue: 235 / 255.0 alpha:1.0];
    contentHtml = [[NSString alloc] init];
    currentContent = [[NSString alloc] init];
    currentId = [[allNewsArray objectAtIndex: currentNum] valueForKey: KINFOCELLID];
    
    topView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 44)];
    topView.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1.0];
    [self.view addSubview: topView];
    
    UIButton *backBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"preview.png"] forState: UIControlStateNormal];
    [backBtn addTarget: self action:@selector(back) forControlEvents: UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(10, 5, 30, 30);
    backBtn.backgroundColor = [UIColor clearColor];
    [topView addSubview: backBtn];
    
    UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake(40, 0, 320 - 80, 44)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.text = @"详细内容";
    [topView addSubview: logoTitle];
    topView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:239 / 255.0 blue:235 / 255.0 alpha:1.0];
    [logoTitle release];
    
    contentView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 44, 320, 460 - 44 - 44)];
    [contentView setBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:239 / 255.0 blue:235 / 255.0 alpha:1.0]];
    [contentView setOpaque:NO]; 
    contentView.scrollView.bounces = NO;
    contentView.delegate = self;
    [self.view addSubview: contentView];
    
    UISwipeGestureRecognizer  *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [contentView addGestureRecognizer:swipeRight];
    [swipeRight release];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [contentView addGestureRecognizer:swipeLeft];
    [swipeLeft release];
    
    toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    UIImage *image = [UIImage imageNamed:@"newsInfoToolbarBg.png"];
    [toolbar setBackgroundImage: image  forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.alpha = 0.6;
    
    favBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    favBtn.frame = CGRectMake(0, 0, 30, 30);
    [favBtn setImage: [UIImage imageNamed: @"infoFavNormal.png"] forState: UIControlStateNormal];
    [favBtn addTarget: self action: @selector(favoriteNew) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithCustomView: favBtn];
 
    UIButton *shareBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 30, 30);
    [shareBtn setImage: [UIImage imageNamed: @"infoShare.png"] forState: UIControlStateNormal];
    [shareBtn addTarget: self action: @selector(shareClick) forControlEvents: UIControlEventTouchUpInside];
    shareItem = [[UIBarButtonItem alloc] initWithCustomView: shareBtn];
    
    UIButton *msgBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    msgBtn.frame = CGRectMake(0, 0, 30, 30);
    [msgBtn setImage: [UIImage imageNamed: @"infoMsg.png"] forState: UIControlStateNormal];
    [msgBtn addTarget: self action: @selector(showComment) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *msgItem = [[UIBarButtonItem alloc] initWithCustomView: msgBtn];
    
    UIButton *prevBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    prevBtn.frame = CGRectMake(0, 0, 30, 30);
    [prevBtn setImage: [UIImage imageNamed: @"infoPrev.png"] forState: UIControlStateNormal];
    [prevBtn addTarget: self action: @selector(prevNew) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithCustomView: prevBtn];
    
    UIButton *nextBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(0, 0, 30, 30);
    [nextBtn setImage: [UIImage imageNamed: @"infoNext.png"] forState: UIControlStateNormal];
    [nextBtn addTarget: self action: @selector(nextNew) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView: nextBtn];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems: [[[NSArray alloc] initWithObjects: favoriteItem, flexibleItem, shareItem, flexibleItem, msgItem, flexibleItem, prevItem, flexibleItem, nextItem, nil] autorelease]];
    
    [self.view addSubview: toolbar];
    
    [favoriteItem release];
    [shareItem release];
    [msgItem release];
    [prevItem release];
    [nextItem release];
    
    [flexibleItem release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    contentView.hidden = YES;
    
    for (UIBarButtonItem *item in [toolbar items]) 
    {
        item.enabled = NO;
    }
    
    [self getNewsDetailInfo: [[allNewsArray objectAtIndex: currentNum] valueForKey: KINFOCELLID]];
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
#pragma mark UIAlertView Delegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self getNewsDetailInfo: [[allNewsArray objectAtIndex: currentNum] valueForKey: KINFOCELLID]];
    }
    else {
        [self back];
    }
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
    for (UIBarButtonItem *item in [toolbar items]) 
    {
        item.enabled = YES;
    }
    
    [MBProgressHUD hideHUDForView: contentView animated: YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (kCFURLErrorCancelled != error.code) //加载被手动取消
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: @"错误" message: @"内容加载失败！" delegate: self cancelButtonTitle: @"重新加载" otherButtonTitles: @"稍后再试", nil];
        [errorAlert show];
        [errorAlert release];
    }
}

#pragma mark -
#pragma mark CMPopTipView Delegate 

- (void)shareByMail: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
        
    [[XDManagerTool Instance] emailInViewController: self title: [[allNewsArray objectAtIndex: currentNum] valueForKey: KDETAILINFOTITLE] body: contentHtml isHtml: YES];
}

- (void)shareByTencentBlog: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
    
    if ([XDManagerTool connectedToNetwork])
    {
        NSString *shareContent = [[NSString alloc] initWithFormat: @"%@%@", [[allNewsArray objectAtIndex: currentNum] objectForKey: KINFOCELLTITLE], [[allNewsArray objectAtIndex: currentNum] objectForKey: KINFOCELLWEBURL]];
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
        NSString *shareContent = [[NSString alloc] initWithFormat: @"%@%@", [[allNewsArray objectAtIndex: currentNum] objectForKey: KINFOCELLTITLE], [[allNewsArray objectAtIndex: currentNum] objectForKey: KINFOCELLWEBURL]];
        [[XDForwardToBlogViewController shareController] shareBySinaBlog: self shareContent: shareContent shareImage: nil];
        [shareContent release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: @"当前网络不给力，请稍后再试！" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
    }
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    
}

#pragma mark - private mothod

-(void)swipe:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self prevNew];
    } 
    else 
    {
        [self nextNew];  
    }
}

//判断当前新闻是否已收藏,若没有收藏用图片infoFavNormal,png；若收藏了用图片infoFavSelected.png
- (void)setFavoriteButtonImg
{
    isFavorite = [XDManagerTool judgeNewsId: [[allNewsArray objectAtIndex: currentNum] objectForKey: KINFOCELLID]];
    if (isFavorite) 
    {
        [favBtn setImage: [UIImage imageNamed: @"infoFavSelected.png"] forState: UIControlStateNormal];
    }
    else
    {
        [favBtn setImage: [UIImage imageNamed: @"infoFavNormal.png"] forState: UIControlStateNormal];
    }
}

- (void)refreshWebView: (NSDictionary *)dictionary
{
    if (dictionary != nil)
    {
        [infoDic removeAllObjects];
        [infoDic addEntriesFromDictionary: dictionary];
        if (currentContent != nil) 
        {
            [currentContent release];
            currentContent = nil;
        }
        if (contentHtml != nil) 
        {
            [contentHtml release];
            contentHtml = nil;
        }
        contentHtml = [[NSString alloc] initWithFormat:@"<body style='background-color:#f0efeb'>%@<div id='new_title'>%@</div><div id='new_outline'>%@</div><hr/><div id='new_body'>%@</div></body>",[XDManagerTool getWebViewHtmlStyle], [dictionary valueForKey: KDETAILINFOTITLE],[dictionary valueForKey: KDETAILINFODATE], [dictionary valueForKey: KDETAILINFOCONTENT]];
        currentContent = [[NSString alloc] initWithString: [dictionary valueForKey: KDETAILINFOCONTENT]];
        
        [contentView loadHTMLString: contentHtml baseURL: [NSURL URLWithString: @"http://66.228.36.17:8000"]];
        [self setFavoriteButtonImg];
    }
}

- (void)getNewsDetailInfo: (NSNumber *)newsId
{
    [MBProgressHUD showHUDAddedTo: contentView  animated: YES];
    
    NSDictionary *result = [[XDDataCenter sharedCenter] getPostDetail: [newsId intValue]  onComplete: ^(NSDictionary *dic)
     {
         [self refreshWebView: dic];
         
         return ;
     }
                                       onError: ^(NSError *error)
     {
         UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: @"错误" message: @"内容加载失败！" delegate: self cancelButtonTitle: @"重新加载" otherButtonTitles: @"稍后再试", nil];
         [errorAlert show];
         
         [errorAlert release];
     }];
    
    [self refreshWebView: result];
}

- (void)favoriteNew
{
    isFavorite = !isFavorite;

    if (isFavorite) 
    {
        [favBtn setImage: [UIImage imageNamed: @"infoFavSelected.png"] forState: UIControlStateNormal];
        [XDManagerTool addNewsToFavorite: [allNewsArray objectAtIndex: currentNum] content: currentContent date: [infoDic objectForKey: KDETAILINFODATE]];
    }
    else 
    {
        [favBtn setImage: [UIImage imageNamed: @"infoFavNormal.png"] forState: UIControlStateNormal];
        [XDManagerTool deleteFavoriteNewsById: currentId];
    }
}

- (void)showComment
{
    if(commentViewController == nil)
    {
        commentViewController = [[XDCommentViewController alloc] init];
    }
    commentViewController.infoId = [[[allNewsArray objectAtIndex: currentNum] valueForKey: KINFOCELLID] intValue];
    
    [self.navigationController pushViewController: commentViewController animated:YES];
}

- (void)shareClick
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
        [popShare presentPointingAtBarButtonItem: shareItem animated:YES];
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
    currentId = [[allNewsArray objectAtIndex: currentNum] objectForKey: KINFOCELLID];
    [self getNewsDetailInfo: currentId];
}

- (void)nextNew
{
    if (currentNum == [allNewsArray count] - 1) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"警告" message: @"已经是最后一篇了" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        
        [alert show];
        [alert release];
        
        return ;
    }
    
    currentNum++;
    currentId = [[allNewsArray objectAtIndex: currentNum] valueForKey: KINFOCELLID];
    [self getNewsDetailInfo: currentId];
}

@end
