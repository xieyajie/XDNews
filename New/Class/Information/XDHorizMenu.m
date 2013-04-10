//
//  XDHorizMenu.m
//  New
//
//  Created by yajie xie on 12-9-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDHorizMenu.h"

#define kButtonBaseTag 10000
#define kLeftOffset 10

@implementation XDHorizMenu

@synthesize titles = _titles;
@synthesize selectedImage = _selectedImage;
@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;
@synthesize lastButtonWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = frame;
        
        self.bounces = YES;
        self.scrollEnabled = YES;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) reloadData
{
    self.itemCount = [dataSource numberOfItemsForMenu:self];
    self.backgroundColor = [dataSource backgroundColorForMenu:self];
    self.selectedImage = [dataSource selectedItemImageForMenu:self];
    
    UIFont *buttonFont = [UIFont boldSystemFontOfSize:13];
    int buttonPadding = 25;
    
    int tag = kButtonBaseTag;    
    int xPos = kLeftOffset;
    
    for (UIView *obj in [self subviews]) 
    {
        if ([obj isKindOfClass: [UIButton class]])
        {
            [obj removeFromSuperview];
        }
    }
    
    for(int i = 0 ; i < self.itemCount; i++)
    {
        NSString *title = [dataSource horizMenu:self titleForItemAtIndex:i];
        UIButton *customButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [customButton setTitleColor:[UIColor colorWithRed: 150 / 255.0 green: 78 / 255.0 blue: 114 / 255.0 alpha: 1.0] forState:UIControlStateNormal];
        [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        customButton.titleLabel.font = buttonFont;
        [customButton setTitle:title forState:UIControlStateNormal];
        
        [customButton setBackgroundImage:self.selectedImage forState:UIControlStateSelected];
        
        customButton.tag = tag++;
        [customButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        int buttonWidth = [title sizeWithFont:customButton.titleLabel.font
                            constrainedToSize:CGSizeMake(150, 28) 
                                lineBreakMode:UILineBreakModeClip].width;
        
        customButton.frame = CGRectMake(xPos, 2, buttonWidth + buttonPadding, 24);
        lastButtonWidth = buttonWidth + buttonPadding;
        xPos += buttonWidth;
        xPos += buttonPadding;
        [self addSubview:customButton];        
    }
    self.contentSize = CGSizeMake(xPos, self.frame.size.height);    
    [self layoutSubviews];  
    
    [self setSelectedIndex:0 animated:YES];
}


-(void) setSelectedIndex:(int) index animated:(BOOL) animated
{
    UIButton *thisButton = (UIButton*) [self viewWithTag:index + kButtonBaseTag]; 
    thisButton.selected = YES;
    [self setContentOffset:CGPointMake(thisButton.frame.origin.x - kLeftOffset, 0) animated:animated];
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

-(void) buttonTapped:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        if(i + kButtonBaseTag == button.tag)
            thisButton.selected = YES;
        else
            thisButton.selected = NO;
    }
    
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}


@end
