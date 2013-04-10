//
//  XDFavoriteViewController.h
//  New
//
//  Created by yajie xie on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XDFavoriteDetailViewController;
@interface XDFavoriteViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    UIImageView *topView;
    UITableView *favoriteList;
    UIButton *editBt;
    
    NSMutableArray *favoriteDataSource;
    XDFavoriteDetailViewController *detailViewController;
}

@end
