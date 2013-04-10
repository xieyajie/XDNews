//
//  XDFavoriteCell.m
//  New
//
//  Created by yajie xie on 12-9-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDFavoriteCell.h"
#import "LocalDefine.h"

@interface XDFavoriteCell ()

- (void)addSubviewsToView;

- (void)setSubviewsFrameNormal;

- (void)setSubviewsFrameEdit;

@end

@implementation XDFavoriteCell

#define KCELLWIDTH 300
#define KCELLHEIGHT 75
#define KTOP 10
#define KLEFT 10
#define KMARGIN 7
#define KIMGWIDTH 60
#define KIMGHEIGHT 50
#define KTITLTHEIGHT 14 
#define KPREVIEWHEIGHT 42
#define KDATEHEIGHT 10

#define KCELLWIDTHEDIT 225

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [UIView beginAnimations:@"ResetFrame" context:nil];
    [UIView setAnimationDuration: 0.7];
    [UIView setAnimationTransition: UIViewAnimationTransitionNone forView: self cache:NO];
    [super willTransitionToState: state];
    
    if (state == UITableViewCellStateDefaultMask)
    {
        NSLog(@"UITableViewCellStateDefaultMask");
        [self setSubviewsFrameNormal];
    }
    else if (state == UITableViewCellStateShowingEditControlMask) 
    {
        NSLog(@"UITableViewCellStateShowingEditControlMask");
    }
    else if (state == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        [self setSubviewsFrameEdit];
        NSLog(@"UITableViewCellStateShowingDeleteConfirmationMask");
    }
    
    [UIView commitAnimations];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        // Initialization code
        [self addSubviewsToView];
    }
    return self;
}

- (NSString *)imgStr
{
    return imgStr;
}

- (NSString *)title
{
    return title;
}

- (NSString *)info
{
    return info;
}

/*- (NSString *)date
{
    return date;
}*/

- (void)setImgStr:(NSString *)aImgStr
{
    imgStr = aImgStr;
    imgView.image = [UIImage imageWithContentsOfFile: aImgStr];
}

- (void)setTitle:(NSString *)aTitle
{
    title = aTitle;
    titleLabel.text = aTitle;
}

- (void)setInfo:(NSString *)aInfo
{
    info = aInfo;
    infoLabel.text = aInfo;
}

/*- (void)setDate:(NSString *)aDate
{
    date = aDate;
    dateLabel.text = aDate;
}*/

- (void)addSubviewsToView
{
    bgImg = [[UIImageView alloc] init];
    bgImg.image = [UIImage imageNamed: @"favoriteCellBg.png"];
    [self.contentView addSubview: bgImg];
  
    imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed: KDEFAULTNEWSCELLIMG];
    [self.contentView addSubview: imgView];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize: 14];
    titleLabel.textAlignment = UITextAlignmentLeft;
    [self.contentView addSubview: titleLabel];
    
    infoLabel = [[UILabel alloc] init ];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont systemFontOfSize: 12];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = UITextAlignmentLeft;
    infoLabel.alpha = 0.8;
    [self.contentView addSubview: infoLabel];
    
    /*dateLabel = [[UILabel alloc] init];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.font = [UIFont systemFontOfSize: 10];
    dateLabel.textAlignment = UITextAlignmentRight;
    dateLabel.alpha = 0.6;
    [self.contentView addSubview: dateLabel];*/
    
    [self setSubviewsFrameNormal];
}

- (void)setSubviewsFrameNormal
{
    bgImg.frame = CGRectMake(KTOP, KLEFT, KCELLWIDTH, KCELLHEIGHT);
    imgView.frame = CGRectMake(KTOP + KMARGIN, KLEFT +KMARGIN, KIMGWIDTH, KIMGHEIGHT);
    
    int labelWidth = KCELLWIDTH - KLEFT - KIMGWIDTH - 2 * KMARGIN;
    titleLabel.frame = CGRectMake(KLEFT + 2 * KMARGIN + KIMGWIDTH, KTOP + KMARGIN, labelWidth, KTITLTHEIGHT);
    infoLabel.frame = CGRectMake(KLEFT + 2 * KMARGIN + KIMGWIDTH, KTOP + KMARGIN * 2 + KTITLTHEIGHT, labelWidth, KPREVIEWHEIGHT);
    //dateLabel.frame = CGRectMake(KLEFT + 2 * KMARGIN + KMARGIN + KIMGWIDTH, KTOP + 3 * KMARGIN + KTITLTHEIGHT + KPREVIEWHEIGHT, labelWidth, KDATEHEIGHT);
}

- (void)setSubviewsFrameEdit
{
    bgImg.frame = CGRectMake(KTOP, KLEFT, KCELLWIDTHEDIT, KCELLHEIGHT);
    imgView.frame = CGRectMake(KTOP + KMARGIN, KLEFT +KMARGIN, KIMGWIDTH, KIMGHEIGHT);
    
    int labelWidth = KCELLWIDTHEDIT - KLEFT - KIMGWIDTH - 2 * KMARGIN;
    titleLabel.frame = CGRectMake(KLEFT + 2 * KMARGIN + KIMGWIDTH, KTOP + KMARGIN, labelWidth, KTITLTHEIGHT);
    infoLabel.frame = CGRectMake(KLEFT + 2 * KMARGIN + KIMGWIDTH, KTOP + KMARGIN * 2 + KTITLTHEIGHT, labelWidth, KPREVIEWHEIGHT);
    //dateLabel.frame = CGRectMake(KLEFT + 2 * KMARGIN + KMARGIN + KIMGWIDTH, KTOP + 3 * KMARGIN + KTITLTHEIGHT + KPREVIEWHEIGHT, labelWidth, KDATEHEIGHT);
}

@end
