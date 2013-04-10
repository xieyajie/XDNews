//
//  XDTabBarController.m
//  New
//
//  Created by yajie xie on 12-9-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDTabBarController.h"
#import "LocalDefine.h"

static BOOL FIRSTTIME =YES;

@interface XDTabBarController ()


- (void)customTabBar;

- (void)slideTabItemBg:(UIButton *)button;

- (void)selectedTabItem: (UIButton *)button;

@end

@implementation XDTabBarController

@synthesize customTabBarView;
@synthesize itemButtons;
@synthesize currentSelectedIndex;
@synthesize viewControllers;

- (void)setControllers: (NSArray *)array
{
    viewControllers = array;
    contentNavigation = [[UINavigationController alloc] initWithRootViewController: [array objectAtIndex:0]];
    [self.view addSubview: contentNavigation.view];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    if (FIRSTTIME) {
		/*[[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideCustomTabBar" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(hideCustomTabBar)
													 name: @"hideCustomTabBar"
												   object: nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"bringCustomTabBarToFront" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(bringCustomTabBarToFront)
													 name: @"bringCustomTabBarToFront"
												   object: nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"setBadge" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setBadge:)
													 name: @"setBadge"
												   object: nil];*/
		
		slideBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedTabbarItemBg.png"]];//选中时阴影层
        slideBg.alpha = 0.5;
		//[self hideRealTabBar];
		[self customTabBar];
		FIRSTTIME = NO;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - custom methods
//- (void)hideRealTabBar
//{
//    for(UIView *view in self.view.subviews)
//    {
//		if([view isKindOfClass:[UITabBar class]])
//        {
//			view.hidden = YES;
//			break;
//		}
//	}
//}

- (void)customTabBar
{
    CGRect tabBarFrame = CGRectMake(0, self.view.frame.size.height - KCustomTabBarHeight, 320, KCustomTabBarHeight);
    customTabBarView = [[UIView alloc] initWithFrame: tabBarFrame];
    tabBarBgImgView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 320, KCustomTabBarHeight)];
    tabBarBgImgView.image = [UIImage imageNamed:@"tabBarBg.png"];
    [customTabBarView addSubview: tabBarBgImgView];
    
    //创建按钮
	int viewCount = viewControllers.count > 5 ? 5 : viewControllers.count;
	self.itemButtons = [NSMutableArray arrayWithCapacity:viewCount];
	double _width = 320 / viewCount;
    double _height = KCustomTabBarHeight;
    for (int i = 0; i < viewCount; i++) 
    {
		UIViewController *v = [viewControllers objectAtIndex:i];
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
		btn.frame = CGRectMake(i * _width, 0, _width, _height);
		[btn addTarget:self action:@selector(selectedTabItem:) forControlEvents: UIControlEventTouchUpInside];
		[btn setImage:v.tabBarItem.image forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
        
		//添加标题
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _height-18, _width, _height-30)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = v.tabBarItem.title;
		[titleLabel setFont:[UIFont systemFontOfSize:10]];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.textColor = [UIColor whiteColor];
		[btn addSubview:titleLabel];		
		
        [self addChildViewController: v];
		[self.itemButtons addObject:btn];
        [customTabBarView addSubview:btn];
        
        [titleLabel release];
	}
    
    [self.view addSubview: customTabBarView];
    [customTabBarView addSubview: slideBg];
    
    [self performSelector:@selector(slideTabItemBg:) withObject:[self.itemButtons objectAtIndex:0]];
    self.currentSelectedIndex = 0;
}

//切换滑块位置
- (void)slideTabItemBg:(UIButton *)button
{
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:0.20];  
	[UIView setAnimationDelegate:self];
	slideBg.frame = button.frame;
	[UIView commitAnimations];
	CAKeyframeAnimation * animation; 
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
	animation.duration = 0.50; 
	animation.delegate = self;
	animation.removedOnCompletion = YES;
	animation.fillMode = kCAFillModeForwards;
	NSMutableArray *values = [NSMutableArray array];
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]]; 
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]]; 
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
	animation.values = values;
	[button.layer addAnimation:animation forKey:nil];
}


- (void)selectedTabItem: (UIButton *)button
{
    if (self.currentSelectedIndex != button.tag)
    {
        [[[viewControllers objectAtIndex: self.currentSelectedIndex] view] removeFromSuperview];
        
		//[[self.viewControllers objectAtIndex:button.tag] popToRootViewControllerAnimated:YES];
        UIViewController *viewController = [viewControllers objectAtIndex:button.tag];
        [self.view addSubview: viewController.view];
        [self.view bringSubviewToFront: self.customTabBarView];
		//return;
        
        [self performSelector:@selector(slideTabItemBg:) withObject:button];
	}
    
	self.currentSelectedIndex = button.tag;
}

@end
