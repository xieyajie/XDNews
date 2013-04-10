//
//  XDHotPictureView.h
//  New
//
//  Created by ed on 12-9-6.
//
//

#import <UIKit/UIKit.h>
#import "HJManagedImageV.h"
#import "CustomBadge.h"

@interface XDHotPictureView : UIView
{
    HJManagedImageV *_managedImageView;
    CustomBadge *_badge;
    UILabel *_title;
}

@property (nonatomic, readonly) HJManagedImageV * managedImageView;
@property (nonatomic, readonly) CustomBadge * badge;
@property (nonatomic, readonly) UILabel *title;

- (XDHotPictureView*)initWithFrame:(CGRect)aFrame oid:(NSString*)aOid url:(NSURL*)aURL number:(NSUInteger)aNumber;

- (void)resetViewWithOid:(NSString*)aOid url:(NSURL*)aURL number:(NSUInteger)aNumber;

@end
