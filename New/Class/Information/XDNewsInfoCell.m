//
//  XDNewsInfoCell.m
//  New
//
//  Created by yajie xie on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDNewsInfoCell.h"
#import "LocalDefine.h"

@implementation XDNewsInfoCell

#define KCELLWIDTH 320
#define KTOP 5
#define KLEFT 5
#define KIMGWIDTH 60
#define KIMGHEIGHT 50
#define KTITLTHEIGHT 14 
#define KPREVIEWHEIGHT 40
#define KDATEHEIGHT 10

@synthesize newsId;
@synthesize newsTitle;
@synthesize newsComment;
@synthesize newsPreview;
@synthesize imgView;

- (void)initSubviews
{
    imgView = [[HJManagedImageV alloc] initWithFrame:CGRectMake(KTOP, KLEFT, KIMGWIDTH, KIMGHEIGHT)];
    imgView.image = [UIImage imageNamed: KDEFAULTNEWSCELLIMG];
    [self.contentView addSubview: imgView];
    
    newsTitle = [[UILabel alloc] initWithFrame: CGRectMake(70, KTOP, KCELLWIDTH - 70 - KLEFT - 50, KTITLTHEIGHT)];
    newsTitle.backgroundColor = [UIColor clearColor];
    newsTitle.font = [UIFont systemFontOfSize: 14];
    [self.contentView addSubview: newsTitle];
    
    newsComment = [[UILabel alloc] initWithFrame: CGRectMake(KCELLWIDTH - KLEFT - 50, KTOP + 3, 50, KDATEHEIGHT)];
    newsComment.backgroundColor = [UIColor clearColor];
    newsComment.font = [UIFont systemFontOfSize: 10];
    newsComment.textAlignment = UITextAlignmentRight;
    newsComment.alpha = 0.6;
    [self.contentView addSubview: newsComment];
    
    newsPreview = [[UILabel alloc] initWithFrame: CGRectMake(70, KTOP + KTITLTHEIGHT, KCELLWIDTH - 70 - KLEFT, KPREVIEWHEIGHT)];
    newsPreview.backgroundColor = [UIColor clearColor];
    newsPreview.numberOfLines = 0;
    newsPreview.font = [UIFont systemFontOfSize: 12];
    newsPreview.alpha = 0.8;
    [self.contentView addSubview: newsPreview];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initSubviews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
