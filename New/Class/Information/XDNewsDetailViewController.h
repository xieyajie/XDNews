//
//  XDNewsDetailViewController.h
//  New
//
//  Created by yajie xie on 12-9-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "XDCommentViewController.h"
#import "CMPopTipView.h"
#import "MBProgressHUD.h"

@interface XDNewsDetailViewController : UIViewController
<UIWebViewDelegate, UIAlertViewDelegate,
CMPopTipViewDelegate>
{
    UIView *topView;
    UIWebView *contentView;
    UIToolbar *toolbar;
    UIButton *favBtn;
    UIBarButtonItem *shareItem;
    
    XDCommentViewController *commentViewController;
    CMPopTipView *popShare;
    
    BOOL isFavorite;
    NSNumber *currentId;
    NSString *contentHtml;
    NSString *currentContent;
    NSMutableArray *allNewsArray;
    NSMutableDictionary *infoDic;
}

@property (nonatomic, assign) NSUInteger currentNum;
@property (nonatomic, strong) NSMutableArray *allNewsArray;

@property (nonatomic, strong) CMPopTipView *popShare;

@end
