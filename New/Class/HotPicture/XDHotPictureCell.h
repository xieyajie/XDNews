//
//  XDHotPictureCell.h
//  New
//
//  Created by dhcdht on 12-9-5.
//
//

#import <UIKit/UIKit.h>
#import "XDHotPictureView.h"

static int kCellMaxPicNum = 2;

@protocol XDHotPictureCellDelegate <NSObject>

@required
- (void)didTappedImageAtLine:(NSUInteger)aLine andIndex:(NSUInteger)aIndex;

@end

@interface XDHotPictureCell : UITableViewCell
{
    NSMutableArray *_picArray;
    id _delegate;
}

@property (nonatomic, readonly) NSMutableArray * picArray;
@property (nonatomic, assign) id<XDHotPictureCellDelegate> delegate;

- (HJManagedImageV*)getManagedImageViewAtIndex:(NSUInteger)aIndex;
- (void)setImageNumAtIndex:(NSUInteger)aIndex number:(NSUInteger)aNumber;
- (void)setTitleAtIndex:(NSUInteger)aIndex title:(NSString*)aTitle;

@end
