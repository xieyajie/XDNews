//
//  XDFavoriteViewController.m
//  New
//
//  Created by yajie xie on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDFavoriteViewController.h"
#import "XDFavoriteDetailViewController.h"
#import "XDTabBarController.h"
#import "XDFavoriteCell.h"
#import "XDManagerTool.h"
#import "LocalDefine.h"

@interface XDFavoriteViewController ()

- (void)editList;

@end

@implementation XDFavoriteViewController

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
    // Do any additional setup after loading the view from its nib.
    self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
    favoriteDataSource = [[NSMutableArray alloc] init];
    
    topView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    topView.image = [UIImage imageNamed: @"topBar.png"];
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(4, 4);
    topView.layer.shadowOpacity = 1.0;
    topView.layer.shadowRadius = 4.0;
    [self.view addSubview: topView];
    
    editBt = [UIButton buttonWithType: UIButtonTypeCustom];
    editBt.frame = CGRectMake(320 - 40, 10, 25, 25);
    [editBt setImage: [UIImage imageNamed: @"favEditNormal.png"] forState: UIControlStateNormal];
    [editBt addTarget: self action:@selector(editList) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: editBt];
    
    UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.textColor = [UIColor whiteColor];
    logoTitle.text = @"我的收藏";
    [topView addSubview: logoTitle];
    [logoTitle release];
    
    favoriteList = [[UITableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, 320, self.view.frame.size.height - KLogoViewHeight)];
    favoriteList.backgroundColor = [UIColor clearColor];
    favoriteList.delegate = self;
    favoriteList.dataSource = self;
    favoriteList.separatorStyle = UITableViewCellSeparatorStyleNone;
    favoriteList.rowHeight = 90;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    int count = [favoriteDataSource count];
    [favoriteDataSource removeAllObjects];
    [favoriteDataSource addObjectsFromArray: [XDManagerTool getAllInfo]];
    
    if ([favoriteDataSource count] != 0) 
    {
        if (count == 0)
        {
            [self.view addSubview: favoriteList];
            [self.view bringSubviewToFront: favoriteList];
        }
        
        favoriteList.editing = NO;
        [editBt setImage: [UIImage imageNamed: @"favEditNormal.png"] forState: UIControlStateNormal];
        [favoriteList reloadData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [favoriteList release];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [favoriteDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [favoriteDataSource objectAtIndex: [indexPath row]];
    
    static NSString* cellIdentifier = @"CellIdecntifier";
    XDFavoriteCell *cell = (XDFavoriteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(nil == cell)
    {
        cell = [[[XDFavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSString *imgUrl = [dic objectForKey: KFAVORITENEWSIMG];
    if (imgUrl && ![imgUrl isEqualToString: @""]) {
        cell.imgStr = imgUrl;
    }
    
    cell.title = [dic objectForKey: KFAVORITENEWSTITLE];
    cell.info =  [dic objectForKey: KFAVORITENEWSBRIEF];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return YES; 
} 

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [XDManagerTool deleteFavoriteNewsById: [[favoriteDataSource objectAtIndex: indexPath.row] objectForKey: KFAVORITENEWSID]];
        
        [favoriteDataSource removeObjectAtIndex: indexPath.row]; 
        // Delete the row from the data source.
        UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
        [cell willTransitionToState: UITableViewCellStateDefaultMask];
        [favoriteList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (detailViewController == nil) 
    {
        detailViewController = [[XDFavoriteDetailViewController alloc] init];
    }
    
    [detailViewController.detailDataSource removeAllObjects];
    [detailViewController.detailDataSource addObjectsFromArray: favoriteDataSource];
    detailViewController.currentNum = indexPath.row;
    [self.navigationController pushViewController: detailViewController animated:YES];
    
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = YES;
}
 

#pragma mark - private methods
- (void)editList
{
    [favoriteList setEditing:!favoriteList.editing animated:YES];
    
    if (favoriteList.editing)
    {
        [editBt setImage: [UIImage imageNamed: @"favEditSelected.png"] forState: UIControlStateNormal];
    }
    else 
    {
        [editBt setImage: [UIImage imageNamed: @"favEditNormal.png"] forState: UIControlStateNormal];
    }
}

@end
