//
//  XDSpecialTopicViewController.m
//  New
//
//  Created by yajie xie on 12-9-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "XDSpecialTopicViewController.h"
#import "XDTopicDetailViewController.h"
#import "XDDataCenter.h"
#import "LocalDefine.h"

@interface XDSpecialTopicViewController ()

@end

@implementation XDSpecialTopicViewController

- (void)refreshDataSource: (NSArray *)array
{
    [dataSourceArray removeAllObjects];
    if (array != nil && [array count] != 0)
    {
        [dataSourceArray addObjectsFromArray: array];
        [topicList reloadData];
    }
}

- (void)getDataSource
{
    NSArray *result = [[XDDataCenter sharedCenter] getProductType: ^(NSArray *array)
                       {
                           [self refreshDataSource: array];
                       }onError: ^(NSError *error)
                       {
                           
                       }];
    [self refreshDataSource: result];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSourceArray = [[NSMutableArray alloc] init];
        [self getDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
    
    
    topView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    topView.image = [UIImage imageNamed: @"topBar.png"];
    
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(4, 4);
    topView.layer.shadowOpacity = 1.0;
    topView.layer.shadowRadius = 4.0;
    
    [self.view addSubview: topView];
    
    UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.textColor = [UIColor whiteColor];
    logoTitle.text = @"分类";
    [topView addSubview: logoTitle];
    
    [logoTitle release];
    
    topicList = [[XDRefreshTableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, 320, self.view.frame.size.height - KLogoViewHeight) pullingDelegate: self];
    //topicList.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
    topicList.delegate = self;
    topicList.dataSource = self;
    topicList.headerOnly = YES;
    [self.view addSubview: topicList];
    
    [self.view bringSubviewToFront: topView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [topView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PullingRefreshTableViewDelegate

- (void)refreshData
{
    [self getDataSource];
    
    [topicList tableViewDidFinishedLoading];
    topicList.reachedTheEnd  = NO;
}

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

#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [topicList tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [topicList tableViewDidEndDragging:scrollView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdecntifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(nil == cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[dataSourceArray objectAtIndex: indexPath.row] valueForKey: KTOPICNAME];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (topicDetailViewController != nil)
    {
        [topicDetailViewController release];
        topicDetailViewController = nil;
    }
    
    topicDetailViewController = [[XDTopicDetailViewController alloc] init];
    topicDetailViewController.topicId = [[[dataSourceArray objectAtIndex: indexPath.row] valueForKey: KTOPICID] stringValue];
    [topicDetailViewController setTopicName: [[dataSourceArray objectAtIndex: indexPath.row] valueForKey: KTOPICNAME]];
    [self.navigationController pushViewController: topicDetailViewController animated: YES];
}


@end
