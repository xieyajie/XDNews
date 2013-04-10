//
//  XDHorizMenu.h
//  New
//
//  Created by yajie xie on 12-9-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XDHorizMenu;
@protocol XDHorizMenuDataSource <NSObject>
@required
- (UIImage*) selectedItemImageForMenu:(XDHorizMenu *) tabView;
- (UIColor*) backgroundColorForMenu:(XDHorizMenu *) tabView;
- (int) numberOfItemsForMenu:(XDHorizMenu *) tabView;

- (NSString*) horizMenu:(XDHorizMenu *) horizMenu titleForItemAtIndex:(NSUInteger) index;
@end

@protocol XDHorizMenuDelegate <NSObject>
@required
- (void)horizMenu:(XDHorizMenu *) horizMenu itemSelectedAtIndex:(NSUInteger) index;
@end


@interface XDHorizMenu : UIScrollView
{
    int _itemCount;
    UIImage *_selectedImage;
    NSMutableArray *_titles;
    id <XDHorizMenuDataSource> dataSource;
    id <XDHorizMenuDelegate> itemSelectedDelegate;
    int lastButtonWidth;
}

@property (nonatomic, retain) NSMutableArray *titles;
@property (nonatomic, assign) id <XDHorizMenuDelegate> itemSelectedDelegate;
@property (nonatomic, retain) id <XDHorizMenuDataSource> dataSource;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, assign) int itemCount;
@property (nonatomic, assign) int lastButtonWidth;

-(void) reloadData;
-(void) setSelectedIndex:(int) index animated:(BOOL) animated;

@end
