//
//  XDFavoriteCell.h
//  New
//
//  Created by yajie xie on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDFavoriteCell : UITableViewCell
{
    UIImageView *bgImg;
    UIImageView *imgView;
    UILabel *titleLabel;
    UILabel *infoLabel;
    //UILabel *dateLabel;
    
    NSString *imgStr;
    NSString *title;
    NSString *info;
    //NSString *date;
}

@property (nonatomic, strong) NSString *imgStr;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *info;
//@property (nonatomic, strong) NSString *date;


@end
