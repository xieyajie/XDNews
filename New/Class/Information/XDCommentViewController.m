//
//  XDCommentViewController.m
//  New
//
//  Created by yajie xie on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "XDCommentViewController.h"
#import "LocalDefine.h"
#import "XDRefreshTableView.h"
#import "XDDataCenter.h"
#import "XDReplyTableViewCell.h"

static int kReplySucceedTag = 0;

@interface XDCommentViewController ()
<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, XDRefreshTableViewDelegate,
UIAlertViewDelegate>
{
    NSUInteger _nextPageNum;
    
    NSMutableArray *_postReplyArray;
    
    XDRefreshTableView *_replyTableView;
    
    UIView *_bottomView;
    UITextField *_textField;
    
    NSString *_parentId;
}

- (void)back;
- (void)fetchReplyInfoWithPageNum:(NSUInteger)aPageNum canUseCache:(BOOL)canUseCache;
- (void)keyBoardChangeFrame:(NSNotification*)notification;
- (void)sendReply:(UIButton*)button;
- (NSDate*)currentDate;

@end

@implementation XDCommentViewController

@synthesize infoId;

#pragma mark - Class life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _infoId = 0;
        _nextPageNum = 1;
        
        _postReplyArray = [[NSMutableArray alloc] init];
        //[self fetchReplyInfoWithPageNum: _nextPageNum canUseCache: YES];
        _nextPageNum++;
        
        _parentId = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, KLogoViewHeight)];
    topView.image = [UIImage imageNamed: @"topBar.png"];
    
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(4, 4);
    topView.layer.shadowOpacity = 1.0;
    topView.layer.shadowRadius = 4.0;
    
    UILabel *logoTitle = [[UILabel alloc] initWithFrame: CGRectMake(40, 0, 320 - 80, 44)];
    logoTitle.textAlignment = UITextAlignmentCenter;
    logoTitle.backgroundColor = [UIColor clearColor];
    logoTitle.textColor = [UIColor whiteColor];
    logoTitle.text = @"评论列表";
    [topView addSubview: logoTitle];
    [logoTitle release];
    
    [self.view addSubview: topView];
    
    UIButton *backBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"preview.png"] forState: UIControlStateNormal];
    [backBtn addTarget: self action:@selector(back) forControlEvents: UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(10, 5, 30, 30);
    backBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview: backBtn];
    
    _bottomView = [[UIView alloc] initWithFrame: CGRectMake(0, 416, 320, 44)];
    _bottomView.backgroundColor = [UIColor colorWithRed: 125 / 255.0f green: 44 / 255.0f blue: 85 / 255.0f alpha: 1.0f];
    [self.view addSubview: _bottomView];
    
    _textField = [[UITextField alloc] initWithFrame: CGRectMake(5, 10, 240, 30)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.placeholder = @"写评论";
    _textField.textColor = [UIColor blackColor];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    [_bottomView addSubview: _textField];
    
    UIButton *bottomButton = [UIButton buttonWithType: UIButtonTypeCustom];
    bottomButton.frame = CGRectMake(250, 10, 45, 30);
    bottomButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    [bottomButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bottomButton setTitle: @"发表" forState: UIControlStateNormal];
    [bottomButton setBackgroundImage: [UIImage imageNamed: @"sendReply.png"] forState: UIControlStateNormal];
    [bottomButton addTarget: self action: @selector(sendReply:) forControlEvents: UIControlEventTouchUpInside];
    [_bottomView addSubview: bottomButton];
    
    _replyTableView = [[XDRefreshTableView alloc] initWithFrame: CGRectMake(0, KLogoViewHeight, 320, 460 - KLogoViewHeight - 44) pullingDelegate: self];
    _replyTableView.headerOnly = NO;
    _replyTableView.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:241 / 255.0 blue:248 / 255.0 alpha:1.0];
    _replyTableView.dataSource = self;
    _replyTableView.delegate = self;
    [self.view addSubview: _replyTableView];
    //[_replyTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyBoardChangeFrame:) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyBoardChangeFrame:) name: UIKeyboardWillHideNotification object: nil];
    
    [self.view bringSubviewToFront: topView];
    [self.view bringSubviewToFront: backBtn];
    [topView release];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)dealloc
{
    [_postReplyArray release];
    [_replyTableView release];
    [_bottomView release];
    [_textField release];
    
    if (_parentId)
    {
        [_parentId release];
        _parentId = nil;
    }
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - @property methods

- (void)setInfoId:(int)aInfoId
{
    if (aInfoId != _infoId)
    {
        _infoId = aInfoId;
        _nextPageNum = 1;
        
        [_postReplyArray removeAllObjects];
        
        [self fetchReplyInfoWithPageNum: _nextPageNum canUseCache: YES];
        _nextPageNum++;
    }
}

#pragma mark - Private methods

- (void)back
{
    [_textField resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)fetchReplyInfoWithPageNum:(NSUInteger)aPageNum canUseCache:(BOOL)canUseCache
{
    NSArray *cacheArray = [[XDDataCenter sharedCenter] getPostReply: _infoId
                                                         andPageNum: aPageNum
                                                         onComplete: ^(NSArray *resultArray){
                                                             
                                                             int updateBeginIndex = KREFRESHTABLEMAXCOUNT * (aPageNum - 1);
                                                             int updateEndIndex = updateBeginIndex + [resultArray count];
                                                             
                                                             for (int i = updateBeginIndex; i < [_postReplyArray count]; i++)
                                                             {
                                                                 [_postReplyArray replaceObjectAtIndex: i withObject: [resultArray objectAtIndex: i-updateBeginIndex]];
                                                             }
                                                             
                                                             for (int i = [_postReplyArray count]; i < updateEndIndex; i++)
                                                             {
                                                                 [_postReplyArray addObject: [resultArray objectAtIndex: i-updateBeginIndex]];
                                                             }
                                                             
                                                             [_replyTableView tableViewDidFinishedLoading];
                                                             _replyTableView.reachedTheEnd = NO;
                                                             
                                                             [_replyTableView reloadData];
                                                         }
                                                            onError: ^(NSError *error){
                                                                
                                                                [_replyTableView tableViewDidFinishedLoading];
                                                                _replyTableView.reachedTheEnd = NO;
                                                            }];
    if (cacheArray && [cacheArray count] && canUseCache)
    {
        int updateBeginIndex = KREFRESHTABLEMAXCOUNT * (aPageNum - 1);
        int updateEndIndex = updateBeginIndex + [cacheArray count];
        
        for (int i = updateBeginIndex; i < [_postReplyArray count]; i++)
        {
            [_postReplyArray replaceObjectAtIndex: i withObject: [cacheArray objectAtIndex: i-updateBeginIndex]];
        }
        
        for (int i = [_postReplyArray count]; i < updateEndIndex; i++)
        {
            [_postReplyArray addObject: [cacheArray objectAtIndex: i-updateBeginIndex]];
        }
        
        [_replyTableView tableViewDidFinishedLoading];
        _replyTableView.reachedTheEnd = NO;
        
        [_replyTableView reloadData];
    }
}

- (void)keyBoardChangeFrame:(NSNotification*)notification
{
    [self.view bringSubviewToFront: _bottomView];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardBeginFrame;
    CGRect keyboardEndFrame;
    
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [[notification.userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBeginFrame];
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = _bottomView.frame;
    keyboardBeginFrame = [self.view convertRect:keyboardBeginFrame toView:nil];
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    newFrame.origin.y += keyboardEndFrame.origin.y - keyboardBeginFrame.origin.y;
    _bottomView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)sendReply:(UIButton*)button
{
    [_textField resignFirstResponder];
    
    if (_textField.text.length != 0)
    {
        [[XDDataCenter sharedCenter] sendReply: _infoId
                                    andContent: _textField.text
                                   andParentID: _parentId onComplete: ^(NSArray *array){
                                       
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                                                       message: @"发表成功"
                                                                                      delegate: self
                                                                             cancelButtonTitle: @"刷新列表"
                                                                             otherButtonTitles: nil];
                                       alert.tag = kReplySucceedTag;
                                       [alert show];
                                       [alert release];
                                   }
                                       onError: ^(NSError *error){
                                           
                                           NSLog(@"%@", error);
                                       }];
        
        if (_parentId)
        {
            [_parentId release];
            _parentId = nil;
        }
        
        _textField.text = @"";
    }
}

- (NSDate*)currentDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [df dateFromString:@"2012-05-03 10:10"];
    [df release];
    return date;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_postReplyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ReplyCellIndentifier";
    
    XDReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (nil == cell)
    {
        cell =
        [[[XDReplyTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                     reuseIdentifier: cellIdentifier] autorelease];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_postReplyArray count] != 0)
    {
        NSUInteger row = [indexPath row];
        
        if (row % 2)
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:241 / 255.0 blue:248 / 255.0 alpha:1.0];
        }
        else
        {
            //cell.contentView.backgroundColor = [UIColor colorWithRed: 125 / 255.0f green: 44 / 255.0f blue: 85 / 255.0f alpha: 1.0f];
            cell.contentView.backgroundColor = [UIColor colorWithRed: 239 / 255.0f green: 228 / 255.0f blue: 241 / 255.0f alpha: 1.0f];
        }
        
        [cell updateCellForDictionary: [_postReplyArray objectAtIndex: row]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [XDReplyTableViewCell heightForDictionary: [_postReplyArray objectAtIndex: [indexPath row]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_parentId)
    {
        [_parentId release];
        _parentId = nil;
    }
    
    _parentId = [[[[_postReplyArray objectAtIndex: [indexPath row]] objectForKey: kREPLYID] stringValue] retain];
    
    [_textField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendReply: nil];
    
    return YES;
}

#pragma mark - XDRefreshTableViewDelegate methods

- (void)pullingTableViewDidStartLoading:(XDRefreshTableView *)tableView
{
    [self fetchReplyInfoWithPageNum: _nextPageNum canUseCache: YES];
    _nextPageNum += 1;
}

- (void)pullingTableViewDidStartRefreshing:(XDRefreshTableView *)tableView
{
    _nextPageNum = 1;
    [_postReplyArray removeAllObjects];
    
    [self fetchReplyInfoWithPageNum: _nextPageNum canUseCache: NO];
    
    _nextPageNum += 1;
}

- (NSDate *)pullingTableViewRefreshingFinishedDate
{
    return [self currentDate];
}

- (NSDate *)pullingTableViewLoadingFinishedDate
{
    return [self currentDate];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_replyTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_replyTableView tableViewDidEndDragging:scrollView];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kReplySucceedTag == alertView.tag)
    {
        _nextPageNum = 1;
        [_postReplyArray removeAllObjects];
        [self fetchReplyInfoWithPageNum: _nextPageNum canUseCache: NO];
        _nextPageNum += 1;
    }
}

@end
