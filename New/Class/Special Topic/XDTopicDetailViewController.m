//
//  XDTopicDetailViewController.m
//  New
//
//  Created by yajie xie on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDTopicDetailViewController.h"
#import "XDNewsDetailViewController.h"
#import "XDNewsInfoCell.h"
#import "XDDataCenter.h"
#import "XDTabBarController.h"
#import "LocalDefine.h"

@interface XDTopicDetailViewController ()

//刷新tableView
- (void)refreshNewsListInfoLoadMore: (BOOL)loadMore;

- (void)refreshData;

- (void)loadMoreData;

- (void)showNewsDetailByIndexPath: (NSIndexPath *)indexPath;

- (void)back:(id)sender;

@end

@implementation XDTopicDetailViewController

@synthesize topicId;

- (void)initSubviews
{
    dataSourceArray = [[NSMutableArray alloc] init];
    arrayByPage = [[NSMutableArray alloc] initWithObjects: [[[NSMutableArray alloc] init] autorelease], nil];
    
    self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
    currentPage = 1;
    
    topView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    topView.image = [UIImage imageNamed: @"topBar.png"];
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(4, 4);
    topView.layer.shadowOpacity = 1.0;
    topView.layer.shadowRadius = 4.0;
    [self.view addSubview: topView];
    
    logoTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.textColor = [UIColor whiteColor];
    [topView addSubview: logoTitle];
    
    UIButton *closeBt = [UIButton buttonWithType: UIButtonTypeCustom];
    [closeBt setImage: [UIImage imageNamed: @"preview.png"] forState: UIControlStateNormal];
    closeBt.frame = CGRectMake(10, 5, 30, 30);
    [closeBt addTarget: self action:@selector(back:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: closeBt];
    
    newsList = [[XDRefreshTableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight , 320,  460 - KCustomTabBarHeight - KLogoViewHeight) pullingDelegate: self];
    newsList.headerOnly = NO;
    newsList.delegate = self;
    newsList.dataSource = self;
    [self.view addSubview: newsList];
    [self.view bringSubviewToFront: topView];
    [self.view bringSubviewToFront: closeBt];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initSubviews];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSString *)topicName
{
    return topicName;
}

- (void)setTopicName:(NSString *)name
{
    topicName = [name retain];
    logoTitle.text = self.topicName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    [self refreshNewsListInfoLoadMore: NO];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KNEWSCELLHEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [dataSourceArray objectAtIndex: indexPath.row];
    static NSString* cellIdentifier = @"CellIdecntifier";
    
    XDNewsInfoCell *cell = (XDNewsInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(nil == cell)
    {
        cell = [[[XDNewsInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSString *imgStr = [dic valueForKey: KINFOCELLIMG];
    cell.imgView.url = [NSURL URLWithString: imgStr];
    cell.imgView.oid = imgStr;
    [[XDDataCenter sharedCenter] managedObject: cell.imgView];
    
    cell.newsId = [[dic valueForKey: KINFOCELLID] stringValue];
    cell.newsTitle.text = [dic valueForKey: KINFOCELLTITLE];
    cell.newsPreview.text = [dic valueForKey: KINFOCELLPREVIEW];
    NSString *tmp = [[NSString alloc] initWithFormat: @"%i%@", [[dic valueForKey: KINFOCELLCOMMENTCOUNT] intValue], @"回复"];
    cell.newsComment.text = tmp;
    [tmp release];

    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath: indexPath] setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    [self showNewsDetailByIndexPath: indexPath];
}

#pragma mark - PullingRefreshTableViewDelegate

//下拉刷新
- (void)pullingTableViewDidStartRefreshing:(XDRefreshTableView *)tableView
{
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:1.f];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [df dateFromString:@"2012-05-03 10:10"];
    [df release];
    return date;
}

//上拉加载
- (void)pullingTableViewDidStartLoading:(XDRefreshTableView *)tableView
{
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:1.f];    
}

#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [newsList tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [newsList tableViewDidEndDragging:scrollView];
}

#pragma mark - custom methods

//获取新闻cell信息
- (void)resetNewsCellArray: (NSArray *)array loadMore: (BOOL)more
{
    if (array != nil && [array count] != 0)
    {
        NSMutableArray *pageArray = [arrayByPage objectAtIndex: (currentPage - 1)];
        [pageArray removeAllObjects];
        [pageArray addObjectsFromArray: array];
        
        [dataSourceArray removeAllObjects];
        if (!more) 
        {
            [dataSourceArray addObjectsFromArray: pageArray];
            [newsList reloadData];
        }
        else if(more)
        {
            [dataSourceArray removeAllObjects];
            
            for (int i = 0; i < [arrayByPage count]; i++) 
            {
                [dataSourceArray addObjectsFromArray: [arrayByPage objectAtIndex: i]];
            }
            
            [newsList reloadData];
        }
        
        [MBProgressHUD hideHUDForView: newsList animated:YES];
    }
}

- (void)refreshNewsCellInfoLoadMore: (BOOL)loadMore
{
    NSArray *result = [[XDDataCenter sharedCenter] getProductList: [self.topicId integerValue] andPageNum: currentPage onComplete: ^(NSArray *array)
                       {
                           [self resetNewsCellArray: array loadMore: loadMore];
                           
                           return ;
                       }
                                                          onError: ^(NSError *error)
                       {
                           
                       }];    
    [self resetNewsCellArray: result loadMore: loadMore];
}

//刷新tableView
- (void)refreshNewsListInfoLoadMore: (BOOL)loadMore
{
    [MBProgressHUD showHUDAddedTo: newsList animated:YES];
    [self refreshNewsCellInfoLoadMore: loadMore];
}

- (void)refreshData
{
    [newsList tableViewDidFinishedLoading];
    newsList.reachedTheEnd  = NO;
    
    currentPage = 1;
    [arrayByPage removeAllObjects];
    [arrayByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
    //重新获取数据
    [self refreshNewsListInfoLoadMore: NO];
}

- (void)loadMoreData
{
    [newsList tableViewDidFinishedLoading];
    newsList.reachedTheEnd  = NO;
    
    [arrayByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
    currentPage++;
    [self refreshNewsCellInfoLoadMore: YES];
}

- (void)showNewsDetailByIndexPath: (NSIndexPath *)indexPath
{
    if (newsDetailViewController == nil)
    {
        newsDetailViewController = [[XDNewsDetailViewController alloc] init];
    }   
    
    [newsDetailViewController.allNewsArray removeAllObjects];
    
    if (dataSourceArray != nil && [dataSourceArray count] != 0)
    {
        [newsDetailViewController.allNewsArray addObjectsFromArray: dataSourceArray];
    }
    
    newsDetailViewController.currentNum = [indexPath row];
    
    [self.navigationController pushViewController: newsDetailViewController animated:YES];
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = YES;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

@end
