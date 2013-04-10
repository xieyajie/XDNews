//
//  XDInformationViewController.m
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDInformationViewController.h"
#import "XDNewsDetailViewController.h"
#import "XDFocusImageViewController.h"
#import "XDTabBarController.h"
#import "XDNewsInfoCell.h"
#import "LocalDefine.h"
#import "XDManagerTool.h"

#import "XDDataCenter.h"

@interface XDInformationViewController ()

- (void)showNewsDetailByIndexPath: (NSIndexPath *)indexPath;

- (void)updateCurrentCity: (NSString *)city;

- (void)updateCurrentWeather: (NSString *)weather;

- (void)refreshData;

- (void)loadMoreData;

@end

@implementation XDInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//资讯中的分类
- (void)resetTypeArray: (NSArray *)array
{
    if (array && [array count] != 0)
    {
        [infoTypeArray removeAllObjects];
        [infoTypeArray addObjectsFromArray: array];
        
        [typeScrollView reloadData];
    }
}

- (void)refreshTypeInfo
{
    NSArray *result = [[XDDataCenter sharedCenter] getPostType: ^(NSArray *typesArray)
     {
        [self resetTypeArray: typesArray];
         
         return ;
     }
                                     onError: ^(NSError *error)
     {
         NSLog(@"%@", error);
     }];
    
    [self resetTypeArray: result];
}

//加载焦点轮显图片
- (void)resetFocusImageArray: (NSArray *)array
{
    [focusImgArray removeAllObjects];
    
    if (array != nil && [array count] != 0) 
    {
        [focusImgArray addObjectsFromArray: array];
        
        [newsList beginUpdates];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex: 0];
        if (newsList.numberOfSections == 1)
        {
            [newsList insertSections: indexSet withRowAnimation: UITableViewRowAnimationFade];
        }
        else {
            [newsList reloadSections: indexSet withRowAnimation: UITableViewRowAnimationFade];
        }
        
        [newsList endUpdates];
    }
}

- (void)refreshFocusImgInfoWithType: (NSUInteger)index
{
    NSArray *array = [[XDDataCenter sharedCenter] getRolling: currentType
                                                  onComplete: ^(NSArray *focusImgs)
                      {
                          [self resetFocusImageArray: focusImgs];
                          
                          return  ;
                      }
                                                     onError: ^(NSError *error)
                      {
                          NSLog(@"Focus img error:%@", error);
                      }];
    
    [self resetFocusImageArray: array];
}

//获取新闻cell信息
- (void)resetNewsCellArray: (NSArray *)array page: (NSInteger)pageNum loadMore: (BOOL)more
{
    if (array != nil && [array count] != 0)
    {
        NSMutableArray *pageArray = [arrayByPage objectAtIndex: (currentPage - 1)];
        [pageArray removeAllObjects];
        [pageArray addObjectsFromArray: array];
        
        [newsCellArray removeAllObjects];
        if (!more) 
        {
            [newsCellArray addObjectsFromArray: pageArray];
            [newsList reloadData];
        }
        else if(more)
        {
            int count = 0;
            for (int i = 0; i < [arrayByPage count]; i++) 
            {
                if (i == ([arrayByPage count] - 1)) 
                {
                    count = [newsCellArray count];
                }
                
                [newsCellArray addObjectsFromArray: [arrayByPage objectAtIndex: i]];
            }

            
            int newsSection = 0;
            if (focusImgArray != 0 && [focusImgArray count] != 0) 
            {
                newsSection = 1;
            }
            
            [newsList beginUpdates];
            NSMutableArray *indexArray = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [array count]; i++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow: (count + i) inSection: newsSection];
                [indexArray addObject: indexPath];
            }
            [newsList insertRowsAtIndexPaths: indexArray withRowAnimation: UITableViewRowAnimationRight];
            [newsList endUpdates];
            
            [indexArray release];
        }
    }
}

- (void)refreshNewsCellInfoWithType: (NSUInteger)index LoadMore: (BOOL)loadMore
{
    int pageNum = currentPage;
    NSArray *result = [[XDDataCenter sharedCenter] getPostList: index andPageNum: currentPage onComplete: ^(NSArray *array)
                       {
                           [self resetNewsCellArray: array page: pageNum loadMore: loadMore];
                           
                           return ;
                       }
                                                       onError: ^(NSError *error)
                       {
                           
                       }];
    
    [self resetNewsCellArray: result page: pageNum loadMore: loadMore];
}

//刷新tableView
- (void)refreshNewsListInfoWithType: (NSUInteger)index LoadMore: (BOOL)loadMore
{
    [MBProgressHUD showHUDAddedTo: newsList animated:YES];
    
    [self refreshFocusImgInfoWithType: index];
    [self refreshNewsCellInfoWithType: index LoadMore: loadMore];
    
    [MBProgressHUD hideHUDForView: newsList animated:YES];
}

//获取城市、天气
- (void)refreshCityAndWeatherInfo
{
    if ([XDManagerTool connectedToNetwork]) 
    {
        [[XDManagerTool Instance] getCityWithCaller: self finishCallMethod: @"updateCurrentCity:"];
        [[XDManagerTool Instance] getWeatherWithCaller: self finishCallMethod: @"updateCurrentWeather:"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
    currentPage = 1;
    currentType = 0;
    
    infoTypeArray = [[NSMutableArray alloc] init];
    focusImgArray = [[NSMutableArray alloc] init];
    
    arrayByPage = [[NSMutableArray alloc] initWithObjects: [[[NSMutableArray alloc] init] autorelease], nil];
    allNewsArray = [[NSMutableArray alloc] init];
    newsCellArray = [[NSMutableArray alloc] init];
    
    topView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    topView.image = [UIImage imageNamed: @"topBar.png"];
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(4, 4);
    topView.layer.shadowOpacity = 1.0;
    topView.layer.shadowRadius = 4.0;
    [self.view addSubview: topView];
    
    UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake((self.view.frame.size.width - 100) / 2, 0, 100, KLogoViewHeight)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.textColor = [UIColor whiteColor];
    logoTitle.text = @"资讯";
    [topView addSubview: logoTitle];
    [logoTitle release];
    
    //获取温度和所在地
    weatherLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width - 110, 5, 100, 20)];
    weatherLabel.textAlignment = UITextAlignmentRight;
    weatherLabel.font = [UIFont systemFontOfSize: 12];
    weatherLabel.backgroundColor = [UIColor clearColor];
    weatherLabel.textColor = [UIColor whiteColor];
    weatherLabel.text = @"";
    [topView addSubview: weatherLabel];
    
    locationLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width - 110, 24, 100, 15)];
    locationLabel.textAlignment = UITextAlignmentRight;
    locationLabel.font = [UIFont systemFontOfSize: 12];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.text = @"";
    [topView addSubview: locationLabel];
    [self refreshCityAndWeatherInfo];

    typeScrollView = [[XDHorizMenu alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, 320, KTypeScrollViewHeight)];
    typeScrollView.dataSource = self;
    typeScrollView.itemSelectedDelegate = self;
    typeScrollView.delegate = self;
    [self.view addSubview: typeScrollView];
    [self refreshTypeInfo];
    
//    newsList = [[XDRefreshTableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight + KTypeScrollViewHeight , 320,  460 - KCustomTabBarHeight - KTypeScrollViewHeight - KLogoViewHeight) pullingDelegate: self];
//    newsList.headerOnly = NO;
//    newsList.delegate = self;
//    newsList.dataSource = self;
//    [self.view addSubview: newsList];
    //[self refreshNewsListInfoWithType: currentType LoadMore: NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];

    self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [typeScrollView release];
    [focusViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark XDFocusImageView Delegate
- (void)foucusImageDidSelectItem:(XDImageView *)item
{
    [self showNewsDetailByIndexPath: [NSIndexPath indexPathForRow: item.tag inSection: 0]];
}

#pragma mark -
#pragma mark HorizMenu Data Source
- (UIImage *) selectedItemImageForMenu:(XDHorizMenu*) tabMenu
{
    return [[UIImage imageNamed:@"selectedTypeBg.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:5];
}


- (UIColor *) backgroundColorForMenu:(XDHorizMenu *)tabView
{
    return [UIColor clearColor];
}
- (int)numberOfItemsForMenu:(XDHorizMenu *)tabView
{
    return [infoTypeArray count];
}

- (NSString *) horizMenu:(XDHorizMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    return [[infoTypeArray objectAtIndex:index] objectForKey: KINFOTYPENAME];
}

#pragma mark -
#pragma mark HorizMenu Delegate
-(void)horizMenu:(XDHorizMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    int type = 1;
    if (infoTypeArray && infoTypeArray.count != 0)
    {
        type = [[[infoTypeArray objectAtIndex: index] objectForKey: KINFOTYPEID] intValue];
    }
    
    if (currentType != type)
    {
        currentType = type;
        currentPage = 1;
        
        [arrayByPage removeAllObjects];
        [arrayByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
        
        if (newsList != nil) 
        {
            [newsList release];
        }
        newsList = [[XDRefreshTableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight + KTypeScrollViewHeight , 320,  460 - KCustomTabBarHeight - KTypeScrollViewHeight - KLogoViewHeight) pullingDelegate: self];
        newsList.headerOnly = NO;
        newsList.delegate = self;
        newsList.dataSource = self;
        [self.view addSubview: newsList];
        
        [self refreshNewsListInfoWithType: type LoadMore: NO];
        //[newsList scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (focusImgArray == nil || [focusImgArray count] == 0) 
    {
        return 1;
    }
    else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    if (focusImgArray != nil && [focusImgArray count] != 0 && section == 0) 
    {
        return KPictureScrollerViewHeight;
    }
    else
    {
        return KNEWSCELLHEIGHT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (focusImgArray != nil && [focusImgArray count] != 0 && section == 0)
    {
        return 1;
    }
    else {
        return [newsCellArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (focusImgArray != nil && [focusImgArray count] != 0 && section == 0)
    {
        if (focusViewController != nil) 
        {
            [focusViewController release];
            focusViewController = nil;
        }
        
        focusViewController = [[XDFocusImageViewController alloc] initWithFrame: CGRectMake(0, 0, 320, KPictureScrollerViewHeight) delegate:self];
        
        static NSString* cellIdentifier1 = @"CellIdecntifier1";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        
        if(nil == cell)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1] autorelease];
            
            [cell.contentView addSubview: focusViewController.view];
        }
        cell.backgroundColor = [UIColor redColor];
        
        [focusViewController setImgInfoArray: focusImgArray];
        [cell.contentView bringSubviewToFront: focusViewController.view];
        
        return cell;
    }
    else
    {
        NSDictionary *dic = [newsCellArray objectAtIndex: row];
        static NSString* cellIdentifier2 = @"CellIdecntifier2";
        
        XDNewsInfoCell *cell = (XDNewsInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        
        if(nil == cell)
        {
            cell = [[[XDNewsInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2] autorelease];
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

- (void)showNewsDetailByIndexPath: (NSIndexPath *)indexPath
{
    if (newsDetailViewController == nil)
    {
        newsDetailViewController = [[XDNewsDetailViewController alloc] init];
    }   
    
    [newsDetailViewController.allNewsArray removeAllObjects];
    if (focusImgArray != nil && [focusImgArray count] != 0)
    {
        [newsDetailViewController.allNewsArray addObjectsFromArray: focusImgArray];
    }
    if (newsCellArray != nil && [newsCellArray count] != 0)
    {
        [newsDetailViewController.allNewsArray addObjectsFromArray: newsCellArray];
    }
    
    if ([indexPath section] == 0) 
    {
        newsDetailViewController.currentNum = [indexPath row];
    }
    else if([indexPath section] == 1)
    {
        newsDetailViewController.currentNum = [indexPath row];
        
        if (focusImgArray != nil && [focusImgArray count] != 0) 
        {
            newsDetailViewController.currentNum += [focusImgArray count];
        }
    }
    
    
    [self.navigationController pushViewController: newsDetailViewController animated:YES];
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = YES;
}

- (void)updateCurrentCity: (NSString *)city
{
    locationLabel.text = city;
}

- (void)updateCurrentWeather: (NSString *)weather
{
    weatherLabel.text = weather;
    [topView bringSubviewToFront: weatherLabel];
}

- (void)refreshData
{
    //[self refreshTypeInfo];
    
    [newsList tableViewDidFinishedLoading];
    newsList.reachedTheEnd  = NO;
    
    currentPage = 1;
    [arrayByPage removeAllObjects];
    [arrayByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
    
    //重新获取数据
    [self refreshNewsListInfoWithType: currentType LoadMore: NO];
}

- (void)loadMoreData
{
    [newsList tableViewDidFinishedLoading];
    newsList.reachedTheEnd  = NO;
    
    [arrayByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
    currentPage++;
    [self refreshNewsCellInfoWithType: currentType LoadMore: YES];
}

@end
