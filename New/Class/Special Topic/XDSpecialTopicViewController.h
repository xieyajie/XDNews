//
//  XDSpecialTopicViewController.h
//  New
//
//  Created by yajie xie on 12-9-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDRefreshTableView.h"

@class XDTopicDetailViewController;
@interface XDSpecialTopicViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UIScrollViewDelegate, XDRefreshTableViewDelegate>
{
    UIImageView *topView;
    XDRefreshTableView *topicList;
    XDTopicDetailViewController *topicDetailViewController;
    
    NSMutableArray *dataSourceArray;
}

@end
