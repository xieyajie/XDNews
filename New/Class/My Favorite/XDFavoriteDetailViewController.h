//
//  XDFavoriteDetailViewController.h
//  New
//
//  Created by yajie xie on 12-9-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CMPopTipView.h"
#import "MBProgressHUD.h"

@interface XDFavoriteDetailViewController : UIViewController
<UIWebViewDelegate, UIAlertViewDelegate,
CMPopTipViewDelegate>
{
    UIWebView *contentView;
    CMPopTipView *popShare;
    
    UIButton *shareBtn;
    UIButton *prevBtn;
    UIButton *nextBtn;
    
    NSString *contentHtml;
}

@property (nonatomic, strong) NSMutableArray *detailDataSource;
@property (nonatomic, assign) NSUInteger currentNum;

@end
