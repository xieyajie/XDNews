//
//  XDFocusImageViewController.m
//  New
//
//  Created by yajie xie on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDFocusImageViewController.h"
#import "XDCustomPageControl.h"
#import "HJManagedImageV.h"
#import "LocalDefine.h"

static NSString *SG_FOCUS_ITEM_ASS_KEY = @"com.touchmob.sgfocusitems";
static CGFloat SWITCH_FOCUS_PICTURE_INTERVAL = 5.0;

@interface XDFocusImageViewController()

- (void)switchFocusImageItems;
- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)moveToTargetPosition:(CGFloat)targetX;

@end


@implementation XDFocusImageViewController

@synthesize delegate;


- (NSArray *)getImgInfoArray
{
    return imgInfoArray;
}

- (void)setImgInfoArray: (NSArray *)array
{
    if ([array count] != 0) 
    {
        [imgInfoArray removeAllObjects];
        [imgInfoArray addObjectsFromArray: array];
        
        [self setSubviews];
    }
}

- (id)initWithFrame: (CGRect)frame delegate:(id<XDFocusImageViewDelegate>)aDelegate focusImageInfoArray: (NSArray *)infoArray
{
    self = [super init];
    if (self) 
    {
        viewFrame = frame;
        self.imgInfoArray = infoArray;
        self.delegate = aDelegate;
    }
    
    return self;
}

- (id)initWithFrame: (CGRect)frame delegate:(id<XDFocusImageViewDelegate>)aDelegate
{
    self = [super init];
    if (self) 
    {
        viewFrame = frame;
        self.delegate = aDelegate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = viewFrame;
    self.view.backgroundColor = [UIColor clearColor];
    imgInfoArray = [[NSMutableArray alloc] init];
    imgViewArray = [[NSMutableArray alloc] init];
    
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    
    pageControl = [[XDCustomPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 25, 100, 25)];
    
    [self.view addSubview: scrollView];
    [self.view addSubview: pageControl];
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:tapGestureRecognize];
    [tapGestureRecognize release];
    
    [self setSubviews];
}

- (void)setSubviews
{
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * imgInfoArray.count, scrollView.frame.size.height);

    pageControl.numberOfPages = imgInfoArray.count;
    pageControl.currentPage = 0;
    [pageControl setImagePageStateNormal:[UIImage imageNamed:@"normalPageImg.png"]];
    [pageControl setImagePageStateHighlighted:[UIImage imageNamed:@"selectedPageImg.png"]];
    
    [self addImageToScroll];
}

- (void)addImageToScroll
{
    [imgViewArray removeAllObjects];
    for (int i = 0; i < imgInfoArray.count; i++) 
    {
        NSDictionary *dic = [imgInfoArray objectAtIndex: i] ;
        XDImageView *viewItem = [[XDImageView alloc] initWithFrame:CGRectMake(i * self.view.frame.size.width, 0, self.view.frame.size.width, scrollView.frame.size.height)];
        viewItem.tag = i;
        
        NSString *str = [dic valueForKey: KINFOCELLIMG];
        viewItem.imgView.url = [NSURL URLWithString: str];
        viewItem.imgView.oid = str;
        [[XDDataCenter sharedCenter] managedObject: viewItem.imgView];
        
        viewItem.imageTitle.text = [dic valueForKey: KINFOCELLTITLE];
        viewItem.newsId = [[dic valueForKey: KINFOCELLID] stringValue];
        
        [scrollView addSubview:viewItem];
        [imgViewArray addObject: viewItem];
        [viewItem release];
    }
    
    [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
}


- (void)switchFocusImageItems
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    
    CGFloat targetX = scrollView.contentOffset.x + scrollView.frame.size.width;
    [self moveToTargetPosition:targetX];
    
    [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (page > -1 && page < imgInfoArray.count)
    {
        XDImageView *item = [imgViewArray objectAtIndex: page];
        if ([self.delegate respondsToSelector:@selector(foucusImageDidSelectItem:)])
        {
            [self.delegate foucusImageDidSelectItem:item];
        }
    }
}


- (void)moveToTargetPosition:(CGFloat)targetX
{
    if (targetX >= scrollView.contentSize.width)
    {
        targetX = 0.0;
    }
    
    [scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES] ;
    pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    pageControl.currentPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    [pageControl pageChange];
}

@end
