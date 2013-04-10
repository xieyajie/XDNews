//
//  XDInformationViewController.h
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDFocusImageViewController.h"
#import "XDHorizMenu.h"
#import "XDRefreshTableView.h"
#import "MBProgressHUD.h"
#import "HJManagedImageV.h"

@class XDNewsDetailViewController;
@interface XDInformationViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate,
UIScrollViewDelegate, MBProgressHUDDelegate,
XDFocusImageViewDelegate, XDHorizMenuDataSource, 
XDHorizMenuDelegate, XDRefreshTableViewDelegate>
{
    UIImageView *topView;
    UILabel *weatherLabel;
    UILabel *locationLabel;
    XDHorizMenu *typeScrollView;
    XDFocusImageViewController *focusViewController;
    XDNewsDetailViewController *newsDetailViewController;
    XDRefreshTableView *newsList;
    
    MBProgressHUD *HUD;
    NSMutableArray *infoTypeArray;
    NSMutableArray *focusImgArray;
    
    NSMutableArray *arrayByPage;
    NSMutableArray *allNewsArray;
    NSMutableArray *newsCellArray;
    
    int currentPage;
    int currentType;
}

@end
