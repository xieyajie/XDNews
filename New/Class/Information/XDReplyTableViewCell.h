//
//  XDReplyTableViewCell.h
//  New
//
//  Created by dhcdht on 12-9-22.
//
//

#import <UIKit/UIKit.h>

@interface XDReplyTableViewCell : UITableViewCell
{
    UILabel *_userNameLabel;
    UILabel *_replyDateLabel;
    UIView *_parentsView;
    UILabel *_replyContentLabel;
}

@property (nonatomic, readonly) UILabel * userNameLabel;
@property (nonatomic, readonly) UILabel * replyDateLabel;
@property (nonatomic, readonly) UILabel * replyContentLabel;
@property (nonatomic, readonly) UIView * parentsView;

+ (float)heightForDictionary:(NSDictionary*)aReplyDictionary;
- (void)updateCellForDictionary:(NSDictionary*)aReplyDictionary;

@end
