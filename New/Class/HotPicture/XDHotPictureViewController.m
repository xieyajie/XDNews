//
//  XDHotPictureViewController.m
//  New
//
//  Created by dhcdht on 12-9-5.
//
//

#import "XDHotPictureViewController.h"
#import "XDPictureScanViewController.h"
#import "XDTabBarController.h"
#import "XDRefreshTableView.h"
#import "XDHotPictureCell.h"
#import "HJManagedImageV.h"
#import "XDDataCenter.h"
#import "LocalDefine.h"

@interface XDHotPictureViewController ()
<UITableViewDataSource, UITableViewDelegate,
XDRefreshTableViewDelegate, XDHotPictureCellDelegate,
UIScrollViewDelegate>
{
    UIImageView *_logoView;
    XDRefreshTableView *_picTableView;
    
    NSMutableArray *_tableViewDataSource;
    NSMutableArray *_dataSourceByPage;
}

- (void)refreshPicSource: (BOOL)loadMore;
- (void)refreshData;
- (void)loadMoreData;

- (NSDate*)currentDate;

@end

@implementation XDHotPictureViewController

#pragma mark - Class life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
    currentPage = 1;
    
    _logoView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    _logoView.image = [UIImage imageNamed: @"topBar.png"];
    [self.view addSubview: _logoView];
    
    UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake((self.view.frame.size.width - 100) / 2, 0, 100, 44)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.textColor = [UIColor whiteColor];
    logoTitle.text = @"热图";
    
    _logoView.layer.shadowColor = [UIColor blackColor].CGColor;
    _logoView.layer.shadowOffset = CGSizeMake(4, 4);
    _logoView.layer.shadowOpacity = 1.0;
    _logoView.layer.shadowRadius = 4.0;
    
    [_logoView addSubview: logoTitle];
    
    [logoTitle release];
    
    _picTableView = [[XDRefreshTableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, 320, self.view.frame.size.height - KLogoViewHeight)
                                              pullingDelegate: self];
    _picTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //_picTableView.backgroundColor = [UIColor redColor];
    _picTableView.headerOnly = NO;
    _picTableView.delegate = self;
    _picTableView.dataSource = self;
    _picTableView.rowHeight = 150.0f;
    _picTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
    [self.view addSubview: _picTableView];
    
    _tableViewDataSource = [[NSMutableArray alloc] init];
    _dataSourceByPage = [[NSMutableArray alloc] initWithObjects: [[[NSMutableArray alloc] init] autorelease], nil];
    [self refreshPicSource: NO];
    
    [self.view bringSubviewToFront: _logoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    //[_picTableView reloadData];
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

- (void)dealloc
{
    [_logoView release];
    [_picTableView release];
    
    [_tableViewDataSource release];
    
    [super dealloc];
}

#pragma mark - XDRefreshTableViewDelegate methods

//下拉刷新
- (void)pullingTableViewDidStartRefreshing:(XDRefreshTableView *)tableView
{
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:1.f];
}

//上拉加载
- (void)pullingTableViewDidStartLoading:(XDRefreshTableView *)tableView
{
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:1.f];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate
{
    return [self currentDate];
}

- (NSDate *)pullingTableViewLoadingFinishedDate
{
    return [self currentDate];
}

#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_picTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_picTableView tableViewDidEndDragging:scrollView];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ( ([_tableViewDataSource count] + 1) / 2 );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"hotPictureCell";
    
    XDHotPictureCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (nil == cell)
    {
        cell =
        [[[XDHotPictureCell alloc] initWithStyle: UITableViewCellStyleDefault
                                 reuseIdentifier: cellIdentifier] autorelease];
        
        cell.delegate = self;
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    
    NSUInteger row = [indexPath row];
    
    int start = row * kCellMaxPicNum;
    int end = (row + 1) * kCellMaxPicNum;
    for (int i = start; i < end; i++)
    {
        if ([_tableViewDataSource count] == i)
        {
            [[cell.picArray objectAtIndex: i-start] setHidden: YES];
        }
        else
        {
            [[cell.picArray objectAtIndex: i-start] setHidden: NO];
            
            [cell setImageNumAtIndex: i-start number: [[[_tableViewDataSource objectAtIndex: i] valueForKey: KHOTPICCOUNT] unsignedIntValue]];
            [cell setTitleAtIndex: i-start title: [[_tableViewDataSource objectAtIndex: i] valueForKey: KHOTPICTITLE]];
            
            NSString *url = [[_tableViewDataSource objectAtIndex: i] valueForKey: KHOTPICIMGURL];
            HJManagedImageV *imgView = [cell getManagedImageViewAtIndex: i-start];
            imgView.oid = url;
            imgView.url = [NSURL URLWithString: url];
            
            [[XDDataCenter sharedCenter] managedObject: imgView];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods



#pragma mark - XDHotPictureCellDelegate methods

- (void)didTappedImageAtLine:(NSUInteger)aLine andIndex:(NSUInteger)aIndex
{
    NSDictionary *dic = [_tableViewDataSource objectAtIndex: aLine*kCellMaxPicNum+aIndex];
    
    if (picScanViewController == nil)
    {
        picScanViewController = [[XDPictureScanViewController alloc] init];
    }
    [picScanViewController setCurrentId: [dic objectForKey: KHOTPICID]];
    [self.navigationController pushViewController: picScanViewController animated: YES];
    
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = YES;
}

#pragma mark - Private methods

- (void)resetPicSource: (NSArray *)array LoadMore: (BOOL)loadMore
{
    if ([array count] != 0)
    {
        NSMutableArray *pageArray = [_dataSourceByPage objectAtIndex: (currentPage - 1)];
        [pageArray removeAllObjects];
        [pageArray addObjectsFromArray: array];
        
        [_tableViewDataSource removeAllObjects];
        if (!loadMore) 
        {
            [_tableViewDataSource addObjectsFromArray: pageArray];
        }
        else 
        {
            for (int i = 0; i < [_dataSourceByPage count]; i++) 
            {
                [_tableViewDataSource addObjectsFromArray: [_dataSourceByPage objectAtIndex: i]];
            }
        }
        [_picTableView reloadData];

    }
}

- (void)refreshPicSource: (BOOL)loadMore
{
    NSArray *result = [[XDDataCenter sharedCenter] getGalleryList: currentPage onComplete: ^(NSArray *array)
     {
         if ([array count] != 0) 
         {
             [self resetPicSource: array LoadMore: loadMore];
         }
         
         return ;
     }
                                        onError: ^(NSError *error)
     {
         NSLog(@"Hot pic error:%@", error);
     }];
    
    [self resetPicSource: result LoadMore: loadMore];
}

- (void)refreshData
{
    [_picTableView tableViewDidFinishedLoading];
    _picTableView.reachedTheEnd  = NO;
    
    currentPage = 1;
    [_dataSourceByPage removeAllObjects];
    [_dataSourceByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
    [self refreshPicSource: NO];
}

- (void)loadMoreData
{
    [_picTableView tableViewDidFinishedLoading];
    _picTableView.reachedTheEnd  = NO;
    
    currentPage++;
    [_dataSourceByPage addObject: [[[NSMutableArray alloc] init] autorelease]];
    [self refreshPicSource: YES];
}

- (NSDate*)currentDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [df dateFromString:@"2012-05-03 10:10"];
    [df release];
    return date;
}

@end
