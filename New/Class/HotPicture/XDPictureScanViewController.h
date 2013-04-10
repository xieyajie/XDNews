//
//  XDPictureScanViewController.h
//  New
//
//  Created by yajie xie on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CMPopTipView.h"
#import "HJManagedImageV.h"

@interface XDPictureInfoView : UIView
{
    HJManagedImageV *imgView;
    UILabel *imgTitle;
}

@property (nonatomic, strong) HJManagedImageV *imgView;
@property (nonatomic, strong) UILabel *imgTitle;

@end


@interface XDPictureScanViewController : UIViewController
<UIScrollViewDelegate, CMPopTipViewDelegate>
{
    UIToolbar *topBar;
    UIScrollView *picScroll;
    CMPopTipView *popShare;
    UILabel *currentNumLabel;
    UILabel *countLabel;
    
    NSMutableArray *picInfoArray;
    NSMutableArray *picImgViewArray;
    
    BOOL isBarAppear;
    NSNumber *currentId;
    int currentPic;
}

- (void)setCurrentId: (NSNumber *)number;

@end
