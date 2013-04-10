//
//  XDReplyTableViewCell.m
//  New
//
//  Created by dhcdht on 12-9-22.
//
//

#import "XDReplyTableViewCell.h"
#import "LocalDefine.h"

static int kMargin = 10;
static int kUserLabelHeight = 20;
static int kParentContentHeight = 35;

@implementation XDReplyTableViewCell

@synthesize userNameLabel = _userNameLabel;
@synthesize replyDateLabel = _replyDateLabel;
@synthesize replyContentLabel = _replyContentLabel;
@synthesize parentsView = _parentsView;

#pragma mark - Class life cycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        _userNameLabel = [[UILabel alloc] init];
        _replyDateLabel = [[UILabel alloc] init];
        _replyContentLabel = [[UILabel alloc] init];
        _parentsView = [[UILabel alloc] init];
        
        _userNameLabel.frame = CGRectMake(kMargin, kMargin, self.contentView.frame.size.width-2*kMargin, kUserLabelHeight);
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = UITextAlignmentLeft;
        
        _replyDateLabel.frame = _userNameLabel.frame;
        _replyDateLabel.backgroundColor = [UIColor clearColor];
        _replyDateLabel.textAlignment = UITextAlignmentRight;
        
        _parentsView.frame = CGRectMake(2*kMargin, 2*kMargin+kUserLabelHeight, self.contentView.frame.size.width - 4*kMargin, kMargin);
        _parentsView.backgroundColor = [UIColor colorWithRed: 245 / 255.0f green: 235 / 255.0f blue: 230 / 255.0f alpha: 1.0f];
        
        _replyContentLabel.frame = CGRectMake(kMargin, _parentsView.frame.origin.y + _parentsView.frame.size.height, self.contentView.frame.size.width-2*kMargin, kMargin);
        _replyContentLabel.backgroundColor = [UIColor clearColor];
        _replyContentLabel.font = [UIFont systemFontOfSize: [UIFont systemFontSize]];
        _replyContentLabel.textAlignment = UITextAlignmentLeft;
        _replyContentLabel.numberOfLines = 0;
        
        [self.contentView addSubview: _userNameLabel];
        [self.contentView addSubview: _replyDateLabel];
        [self.contentView addSubview: _replyContentLabel];
        [self.contentView addSubview: _parentsView];
    }
    return self;
}

- (void)dealloc
{
    [_userNameLabel release];
    [_replyDateLabel release];
    [_replyContentLabel release];
    [_parentsView release];
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public methods

+ (float)heightForDictionary:(NSDictionary*)aReplyDictionary
{
    int parentsCount = [(NSArray*)[aReplyDictionary objectForKey: KREPLYPARENTS] count];
    
    NSString *content = [aReplyDictionary objectForKey: KREPLYCONTENT];
    int contentHeith = [content sizeWithFont: [UIFont systemFontOfSize: [UIFont systemFontSize]] constrainedToSize: CGSizeMake(320-2*kMargin, CGFLOAT_MAX) lineBreakMode: UILineBreakModeWordWrap].height;
    
    int result = (4 * kMargin) + kUserLabelHeight + (parentsCount * (kUserLabelHeight + kParentContentHeight)) + contentHeith;
    
    return result;
}

- (void)updateCellForDictionary:(NSDictionary*)aReplyDictionary
{
    _userNameLabel.text = [aReplyDictionary objectForKey: KREPLYUSER];
    _replyDateLabel.text = [aReplyDictionary objectForKey: KREPLYPUBDATE];
    
    for (UIView *view in [_parentsView subviews])
    {
        [view removeFromSuperview];
    }
    
    int parentsCount = [[aReplyDictionary objectForKey: KREPLYPARENTS] count];
    _parentsView.frame = CGRectMake(2*kMargin, 2*kMargin + kUserLabelHeight, _parentsView.bounds.size.width, parentsCount * (kParentContentHeight + kUserLabelHeight));
    
    int parentHeight = 1;
    for (int i = [[aReplyDictionary objectForKey: KREPLYPARENTS] count]-1; i >= 0; i--)
    {
        NSDictionary *dic = [[aReplyDictionary objectForKey: KREPLYPARENTS] objectAtIndex: i];
        UILabel *userNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(kMargin, parentHeight, _parentsView.frame.size.width-2*kMargin, kUserLabelHeight)];
        userNameLabel.text = [dic objectForKey: KREPLYUSER];
        userNameLabel.backgroundColor = [UIColor colorWithRed: 244 / 255.0f green: 226 / 255.0f blue: 247 / 255.0f alpha: 1.0f];
        userNameLabel.textAlignment = UITextAlignmentLeft;
        [_parentsView addSubview: userNameLabel];
        [userNameLabel release];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame: userNameLabel.frame];
        dateLabel.text = [dic objectForKey: KREPLYPUBDATE];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = UITextAlignmentRight;
        [_parentsView addSubview: dateLabel];
        [dateLabel release];
        
        parentHeight += userNameLabel.frame.size.height;
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, parentHeight, _parentsView.frame.size.width, kParentContentHeight)];
        contentLabel.text = [dic objectForKey: KREPLYCONTENT];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = UITextAlignmentLeft;
        [_parentsView addSubview: contentLabel];
        [contentLabel release];
        
        parentHeight += contentLabel.frame.size.height;
    }
    
    _replyContentLabel.text = [aReplyDictionary objectForKey: KREPLYCONTENT];
    int contentHeight = [_replyContentLabel.text sizeWithFont: [UIFont systemFontOfSize: [UIFont systemFontSize]] constrainedToSize: CGSizeMake(320-2*kMargin, CGFLOAT_MAX) lineBreakMode: UILineBreakModeWordWrap].height;
    _replyContentLabel.frame = CGRectMake(_replyContentLabel.frame.origin.x, _parentsView.frame.origin.y + _parentsView.frame.size.height + kMargin, _replyContentLabel.frame.size.width, contentHeight);
}

@end
