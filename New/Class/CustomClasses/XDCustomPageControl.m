//
//  XDCustomPageControl.m
//  New
//
//  Created by yajie xie on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDCustomPageControl.h"

@interface XDCustomPageControl(private)  // 声明一个私有方法, 该方法不允许对象直接使用
- (void)updateDots;
@end

@implementation XDCustomPageControl

@synthesize imagePageStateNormal;
@synthesize imagePageStateHighlighted;

- (void)pageChange
{
    [self updateDots];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// 设置正常状态点按钮的图片
- (void)setImagePageStateNormal:(UIImage*)image
{  
    imagePageStateNormal = [image copy];
    [self updateDots];
}

// 设置高亮状态点按钮图片
-(void)setImagePageStateHighlighted:(UIImage *)image 
{ 
    imagePageStateHighlighted = [image copy];
    [self updateDots];
}

// 点击事件
- (void)endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent *)event 
{ 
    [super endTrackingWithTouch:touch withEvent:event];
    [self updateDots];
}

// 更新显示所有的点按钮
- (void)updateDots
{ 
    if(imagePageStateNormal || imagePageStateHighlighted)
    {
        NSArray *subview = self.subviews;  // 获取所有子视图
        for(NSInteger i = 0; i < [subview count]; i++)
        {
            UIImageView *dot = [subview objectAtIndex:i];
            CGRect r = dot.frame;
            dot.frame = CGRectMake(r.origin.x, r.origin.y, 20, 15);
            dot.image = self.currentPage == i ? imagePageStateHighlighted : imagePageStateNormal;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
