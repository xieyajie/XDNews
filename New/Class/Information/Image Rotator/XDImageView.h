//
//  XDImageView.h
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

@interface XDImageView : UIView
{
    HJManagedImageV *imgView;
    UILabel *imageTitle;
    UIView *shadowView;
}

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) HJManagedImageV *imgView;
@property (nonatomic, strong) UILabel *imageTitle;

@end
