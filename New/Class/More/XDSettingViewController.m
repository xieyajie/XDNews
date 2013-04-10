//
//  XDSettingViewController.m
//  New
//
//  Created by dhcdht on 12-9-8.
//
//
#import <QuartzCore/QuartzCore.h>
#import "XDSettingViewController.h"
#import "LocalDefine.h"
#import "XDDataCenter.h"
#import "XDAboutViewController.h"

@interface XDSettingViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    UIImageView *_logoView;
    UITableView *_settingTableView;
    
    NSMutableArray *_tableViewDataSource;
    
    NSMutableDictionary *_settingDic;
}

- (void)fontSizeValueChanged:(id)aObject;
- (void)newsPushValueChanged:(id)aObject;
- (void)offLineValueChanged:(id)aObject;

- (void)saveSetting;

@end

@implementation XDSettingViewController

#pragma mark - Class life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.frame = CGRectMake(0, 0, 320, 460 - KCustomTabBarHeight);
        
        NSString *settingPath = [NSHomeDirectory() stringByAppendingPathComponent: KSETTINGPLIST];
        if ([[NSFileManager defaultManager] fileExistsAtPath: settingPath])
        {
            _settingDic = [[NSMutableDictionary alloc] initWithContentsOfFile: settingPath];
        }
        else
        {
            [[NSFileManager defaultManager] createFileAtPath: settingPath contents: nil attributes: nil];
            
            _settingDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt: 1], KFONTSIZEKEY, [NSNumber numberWithBool: YES], KNEWSPUSHKEY, [NSNumber numberWithBool:NO], KOFFLINEKEY, nil];
            
            [_settingDic writeToFile: settingPath atomically: YES];
        }
        
        _logoView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
        _logoView.image = [UIImage imageNamed: @"topBar.png"];
        
        _logoView.layer.shadowColor = [UIColor blackColor].CGColor;
        _logoView.layer.shadowOffset = CGSizeMake(4, 4);
        _logoView.layer.shadowOpacity = 1.0;
        _logoView.layer.shadowRadius = 4.0;
        
        [self.view addSubview: _logoView];
        
        UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake((self.view.frame.size.width - 100) / 2, 0, 100, 44)];
        logoTitle.textAlignment = UITextAlignmentCenter;
        logoTitle.backgroundColor = [UIColor clearColor];
        logoTitle.textColor = [UIColor whiteColor];
        logoTitle.text = @"设置";
        [_logoView addSubview: logoTitle];
        
        [logoTitle release];
        
        UIView *backView = [[UIView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, 320, self.view.bounds.size.height - KLogoViewHeight)];
        backView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
        [self.view addSubview: backView];
        
        _settingTableView = [[UITableView alloc] initWithFrame: backView.frame
                                                         style: UITableViewStyleGrouped];
        _settingTableView.dataSource = self;
        _settingTableView.delegate = self;
        //_settingTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"tableBg.png"]];
        _settingTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview: _settingTableView];
        
        [self.view bringSubviewToFront: _logoView];
        
        [backView release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_settingTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [self saveSetting];
    
    [_settingDic release];
    
    [_logoView release];
    [_settingTableView release];
    [_tableViewDataSource release];
    
    [super dealloc];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 1)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"阅读设置";
            break;
            
        case 1:
            return @"订阅设置";
            break;
            
        case 2:
            return @"缓存控制";
            break;
            
        case 3:
            return @"产品信息";
            break;
            
        default:
            break;
    }
    return @"Demo";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"settingCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
//    if (nil == cell)
//    {
//        cell =
//        [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
//                                reuseIdentifier: cellIdentifier] autorelease];
//    }
    UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section)
    {
        case 0:
            switch (row)
            {
                case 0:
                    cell.textLabel.text = @"字体大小";
                    
                    NSArray *segments = [NSArray arrayWithObjects:@"小", @"中", @"大", nil];
                    UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems: segments];
                    [segmented addTarget: self action: @selector(fontSizeValueChanged:) forControlEvents: UIControlEventValueChanged];
                    segmented.frame = CGRectMake(cell.frame.size.width - segmented.frame.size.width-19, 0, segmented.frame.size.width, segmented.frame.size.height+1);
                    [cell.contentView addSubview: segmented];
                    
                    [segmented setSelectedSegmentIndex: [[_settingDic objectForKey: KFONTSIZEKEY] intValue]];
                    
                    [segmented release];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
            }
            break;
            
        case 1:
            switch (row)
            {
                case 0:
                {
                    cell.textLabel.text = @"消息推送";
                    
                    UISwitch *sw = [[UISwitch alloc] init];
                    [sw addTarget: self action: @selector(newsPushValueChanged:) forControlEvents: UIControlEventValueChanged];
                    sw.frame = CGRectMake(cell.frame.size.width - sw.frame.size.width - 25, (cell.frame.size.height - sw.frame.size.height) / 2, cell.frame.size.width, cell.frame.size.height);
                    [cell.contentView addSubview: sw];
                    
                    if (1 == [[_settingDic objectForKey: KNEWSPUSHKEY] intValue])
                    {
                        [sw setOn: YES];
                    }
                    else
                    {
                        [sw setOn: NO];
                    }
                    
                    [sw release];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                }
                    
                case 1:
                {
                    cell.textLabel.text = @"离线阅读";
                    
                    UISwitch *sw = [[UISwitch alloc] init];
                    [sw addTarget: self action: @selector(offLineValueChanged:) forControlEvents: UIControlEventValueChanged];
                    sw.frame = CGRectMake(cell.frame.size.width - sw.frame.size.width - 25, (cell.frame.size.height - sw.frame.size.height) / 2, cell.frame.size.width, cell.frame.size.height);
                    [cell.contentView addSubview: sw];
                    
                    if (1 == [[_settingDic objectForKey: KOFFLINEKEY] intValue])
                    {
                        [sw setOn: YES];
                    }
                    else
                    {
                        [sw setOn: NO];
                    }
                    
                    [sw release];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                }
            }
            break;
            
        case 2:
            switch (row)
            {
                case 0:
                    cell.textLabel.text = @"清除缓存";
                    
                    UILabel *cacheSizeLabel = [[UILabel alloc] init];
                    NSUInteger cacheSize = [[XDDataCenter sharedCenter] cacheSize];
                    if (cacheSize < 1024)
                    {
                        cacheSizeLabel.text = [NSString stringWithFormat: @"%u B", cacheSize];
                    }
                    else if (cacheSize < 1024 * 1024)
                    {
                        cacheSizeLabel.text = [NSString stringWithFormat: @"%.2f KB", (cacheSize * 1.0f) / 1024];
                    }
                    else if (cacheSize < 1024 * 1024 * 1024)
                    {
                        cacheSizeLabel.text = [NSString stringWithFormat: @"%.2f MB", (cacheSize * 1.0f) / (1024 * 1024)];
                    }
                    else
                    {
                        cacheSizeLabel.text = [NSString stringWithFormat: @"%.2f GB", (cacheSize * 1.0f) / (1024 * 1024 * 1024)];
                    }
                    cacheSizeLabel.frame = CGRectMake(230, 0, 50, 40);
                    cacheSizeLabel.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview: cacheSizeLabel];
                    
                    [cacheSizeLabel release];
                    
                    break;
            }
            break;
            
        case 3:
            switch (0)
            {
                case 0:
                    cell.textLabel.text = @"关于";
                    
                    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
                    break;
            }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if ([indexPath section] == 2)
    {
        [[XDDataCenter sharedCenter] cleanCache];
        [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
    if ([indexPath section] == 3)
    {
        XDAboutViewController *aboutViewController = [[XDAboutViewController alloc] init];
        [self.navigationController pushViewController: aboutViewController animated: YES];
        [aboutViewController release];
    }
}

#pragma mark - Private methods

- (void)fontSizeValueChanged:(id)aObject;
{
    UISegmentedControl *segmented = (UISegmentedControl*)aObject;
    
    [_settingDic setValue: [NSNumber numberWithInt: segmented.selectedSegmentIndex] forKey: KFONTSIZEKEY];
    
    [self saveSetting];
}

- (void)newsPushValueChanged:(id)aObject
{
    UISwitch *sw = (UISwitch*)aObject;
    
    [_settingDic setValue: [NSNumber numberWithBool: sw.on] forKey: KNEWSPUSHKEY];
    
    [self saveSetting];
}

- (void)offLineValueChanged:(id)aObject
{
    UISwitch *sw = (UISwitch*)aObject;
    
    [_settingDic setValue: [NSNumber numberWithBool: sw.on] forKey: KOFFLINEKEY];
    
    [self saveSetting];
}

- (void)saveSetting
{
    NSString *settingPath = [NSHomeDirectory() stringByAppendingPathComponent: KSETTINGPLIST];
    [_settingDic writeToFile: settingPath atomically: YES];
}

@end
