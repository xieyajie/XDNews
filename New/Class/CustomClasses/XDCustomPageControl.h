//
//  XDCustomPageControl.h
//  New
//
//  Created by yajie xie on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDCustomPageControl : UIPageControl
{
    UIImage* imagePageStateNormal;
    UIImage* imagePageStateHighlighted;
}

@property (nonatomic, retain) UIImage* imagePageStateNormal;
@property (nonatomic, retain) UIImage* imagePageStateHighlighted;

- (id)initWithFrame:(CGRect)frame;
- (void)pageChange;

@end
