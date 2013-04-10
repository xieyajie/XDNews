//
//  XDImageView.m
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDImageView.h"
#import "LocalDefine.h"

@implementation XDImageView

#define KImageViewTitleHeight 25

@synthesize newsId;
@synthesize imgView;
@synthesize imageTitle;

- (void)initSubviews
{
    imgView = [[HJManagedImageV alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imgView.image = [UIImage imageNamed: KDEFAULTFOCUSIMG];
    [self addSubview: imgView];
    
    shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - KImageViewTitleHeight, self.frame.size.width, KImageViewTitleHeight)];
    shadowView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"imageViewTitleBg.png"]];
    shadowView.alpha = 0.9;
    [self addSubview: shadowView];
    [self bringSubviewToFront: shadowView];
    
    imageTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width, KImageViewTitleHeight)];
    imageTitle.backgroundColor = [UIColor clearColor];
    imageTitle.textColor = [UIColor blackColor];
    imageTitle.textAlignment = UITextAlignmentLeft;
    imageTitle.font = [UIFont systemFontOfSize:15.0];
    imageTitle.numberOfLines = 0;
    [shadowView addSubview:imageTitle];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = frame;
        [self initSubviews];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
