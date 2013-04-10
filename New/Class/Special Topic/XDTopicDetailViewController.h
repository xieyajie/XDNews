//
//  XDTopicDetailViewController.h
//  New
//
//  Created by yajie xie on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "XDRefreshTableView.h"

@class XDNewsDetailViewController;
@interface XDTopicDetailViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UIScrollViewDelegate,XDRefreshTableViewDelegate>
{
    UIImageView *topView;
    UILabel *logoTitle;
    XDRefreshTableView *newsList;
    XDNewsDetailViewController *newsDetailViewController;
    
    NSMutableArray *dataSourceArray;
    NSMutableArray *arrayByPage;
    NSString *topicName;
    
    int currentPage;
}

@property (nonatomic, strong) NSString *topicId;

- (NSString *)topicName;
- (void)setTopicName:(NSString *)name;

@end
