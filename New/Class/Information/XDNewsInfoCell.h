//
//  XDNewsInfoCell.h
//  New
//
//  Created by yajie xie on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"

@interface XDNewsInfoCell : UITableViewCell
{
    NSString *newsId;
    HJManagedImageV *imgView;
    UILabel *newsTitle;
    UILabel *newsComment;
    UILabel *newsPreview;
}

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) HJManagedImageV *imgView;
@property (nonatomic, strong) UILabel *newsTitle;
@property (nonatomic, strong) UILabel *newsComment;
@property (nonatomic, strong) UILabel *newsPreview;


@end
