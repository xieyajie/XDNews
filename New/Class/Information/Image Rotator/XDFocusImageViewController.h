//
//  XDFocusImageViewController.h
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDDataCenter.h"
#import "XDImageView.h"

@protocol XDFocusImageViewDelegate;

@class XDCustomPageControl;
@interface XDFocusImageViewController : UIViewController
<UIScrollViewDelegate>
{
    CGRect viewFrame;
    
    UIScrollView *scrollView;
    XDCustomPageControl *pageControl;
    
    NSMutableArray *imgInfoArray;
    NSMutableArray *imgViewArray;
}

@property (nonatomic, assign) id<XDFocusImageViewDelegate> delegate;

- (id)initWithFrame: (CGRect)frame delegate:(id<XDFocusImageViewDelegate>)aDelegate;

- (id)initWithFrame: (CGRect)frame delegate:(id<XDFocusImageViewDelegate>)aDelegate focusImageInfoArray: (NSArray *)infoArray;

- (NSArray *)getImgInfoArray;

- (void)setImgInfoArray: (NSArray *)array;

- (void)addImageToScroll;

@end

#pragma mark - XDFocusImageViewDelegate
@protocol XDFocusImageViewDelegate <NSObject>

- (void)foucusImageDidSelectItem:(XDImageView *)item;

@end
