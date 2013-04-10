//
//  XDHotPictureCell.m
//  New
//
//  Created by dhcdht on 12-9-5.
//
//

#import "XDHotPictureCell.h"

static int kLeftMarge = 5;
static int kTopMarge = 10;
static int kPicSize = 130;
static int kCenterSpace = 40;

@interface XDHotPictureCell ()
{
    UITapGestureRecognizer *_tapGesture;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)aTapGesture;

@end

@implementation XDHotPictureCell

@synthesize picArray = _picArray;
@synthesize delegate = _delegate;

#pragma mark - Class life cycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _picArray = [[NSMutableArray alloc] initWithCapacity: kCellMaxPicNum];
        
        for (int i = 0; i < kCellMaxPicNum; i++)
        {
            XDHotPictureView *view =
            [[XDHotPictureView alloc] initWithFrame:
             CGRectMake(kLeftMarge+i*(kPicSize+kCenterSpace),
                        kTopMarge, kPicSize, kPicSize)
                                                oid: nil
                                                url: nil
                                             number: 0];
            [_picArray addObject: view];
            [self.contentView addSubview: view];
            [view release];
        }
        
        _tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(handleTapGesture:)];
        [self.contentView addGestureRecognizer: _tapGesture];
    }
    return self;
}

- (void)dealloc
{
    [_picArray release];
    
    [self.contentView removeGestureRecognizer: _tapGesture];
    [_tapGesture release];
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Private methods

- (void)handleTapGesture:(UITapGestureRecognizer*)aTapGesture
{
    for (int i = 0; i < [_picArray count]; i++)
    {
        CGPoint pt = [aTapGesture locationInView: [_picArray objectAtIndex: i]];
        
        if ([[_picArray objectAtIndex: i] pointInside: pt withEvent: nil])
        {
            NSIndexPath *indexPath = [(UITableView*)self.superview indexPathForCell: self];
            NSUInteger lineNum = [indexPath row];
            if (_delegate && [_delegate respondsToSelector: @selector(didTappedImageAtLine:andIndex:)])
            {
                [_delegate didTappedImageAtLine: lineNum andIndex: i];
            }
        }
    }
}

#pragma mark - Public methods

- (HJManagedImageV*)getManagedImageViewAtIndex:(NSUInteger)aIndex
{
    return [(XDHotPictureView*)[_picArray objectAtIndex: aIndex] managedImageView];
}

- (void)setImageNumAtIndex:(NSUInteger)aIndex number:(NSUInteger)aNumber
{
    ((XDHotPictureView*)[_picArray objectAtIndex: aIndex]).badge.badgeText = [NSString stringWithFormat: @"%u", aNumber];
}

- (void)setTitleAtIndex:(NSUInteger)aIndex title:(NSString*)aTitle
{
    ((XDHotPictureView*)[_picArray objectAtIndex: aIndex]).title.text = aTitle;
}

@end