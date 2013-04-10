//
//  XDPictureScanViewController.m
//  New
//
//  Created by yajie xie on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XDPictureScanViewController.h"
#import "XDTabBarController.h"
#import "XDForwardToBlogViewController.h"
#import "XDManagerTool.h"
#import "XDDataCenter.h"
#import "LocalDefine.h"

@implementation XDPictureInfoView

@synthesize imgView;
@synthesize imgTitle;

- (void)initSubviews
{
    imgView = [[HJManagedImageV alloc] initWithFrame:CGRectMake(10 , 10, self.frame.size.width - 20, self.frame.size.height - 20)];
    imgView.image = [UIImage imageNamed: KDEFAULTPICDETAIL];
    [self addSubview: imgView];
    
    imgTitle = [[UILabel alloc] initWithFrame: CGRectMake(5, self.frame.size.height - 10 - 20, self.frame.size.width - 10, 20)];
    imgTitle.backgroundColor = [UIColor clearColor];
    imgTitle.alpha = 0.8;
    imgTitle.textColor = [UIColor whiteColor];
    [self addSubview: imgTitle];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        // Custom initialization
        self.frame = frame;
        [self initSubviews];
    }
    return self;
}

@end


@interface XDPictureScanViewController ()

- (void)getPicDataSource;

- (void)back;

- (void)sharePic;

- (void)savePicToLocal;

- (void)addPictureToScroll;

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation XDPictureScanViewController

- (void)initSubviews
{
    topBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
    topBar.barStyle = UIBarStyleBlackTranslucent;
    topBar.translucent = YES;
    topBar.alpha = 0.6;
    [self.view addSubview: topBar];
    
    UIButton *closeBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [closeBt setImage: [UIImage imageNamed: @"preview.png"] forState: UIControlStateNormal];
    [closeBt addTarget: self action:@selector(back) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView: closeBt];
    [closeBt release];
    
    UIButton *downloadBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [downloadBt setImage: [UIImage imageNamed: @"download.png"] forState: UIControlStateNormal];
    [downloadBt addTarget: self action:@selector(savePicToLocal) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *downloadItem = [[UIBarButtonItem alloc] initWithCustomView: downloadBt];
    [downloadBt release];
    
    UIButton *shareBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [shareBt setImage: [UIImage imageNamed: @"favShare.png"] forState: UIControlStateNormal];
    [shareBt addTarget: self action:@selector(sharePic) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView: shareBt];
    [shareBt release];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 44)];
    label.backgroundColor = [UIColor clearColor];
    currentNumLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 50, 44)];
    currentNumLabel.textAlignment = UITextAlignmentRight;
    currentNumLabel.textColor = [UIColor whiteColor];
    currentNumLabel.backgroundColor = [UIColor clearColor];
    currentNumLabel.text = @"";
    countLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 0, 50, 44)];
    countLabel.textAlignment = UITextAlignmentLeft;
    countLabel.textColor = [UIColor whiteColor];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.text = @"";
    [label addSubview: currentNumLabel];
    [label addSubview: countLabel];
    UIBarButtonItem *countItem = [[UIBarButtonItem alloc] initWithCustomView: label];
    [label release];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *itemArray = [[NSArray alloc] initWithObjects: closeItem, flexibleItem, countItem, flexibleItem, shareItem, downloadItem, nil];
    [topBar setItems: itemArray animated: YES];
    
    [closeItem release];
    [downloadItem release];
    [shareItem release];
    [countItem release];
    [flexibleItem release];
    [itemArray release];
    
    picScroll = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 10, 320, self.view.frame.size.height - 20)];
    picScroll.backgroundColor = [UIColor blackColor];
    picScroll.pagingEnabled = YES;
    picScroll.delegate = self;
    picScroll.showsHorizontalScrollIndicator = NO;
    picScroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview: picScroll];
    
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.numberOfTapsRequired = 1;
    [picScroll addGestureRecognizer:tapGestureRecognize];
    [tapGestureRecognize release];
    
    [self.view bringSubviewToFront: topBar];
}

- (void)setPicInfoArray: (NSArray *)array
{
    [picInfoArray removeAllObjects];
    [picInfoArray addObjectsFromArray: array];
    
    currentNumLabel.text = @"1";
    NSString *count = [[NSString alloc] initWithFormat: @"/%i", [picInfoArray count]];
    countLabel.text = count;
    [count release];
    picScroll.contentSize = CGSizeMake(picScroll.frame.size.width * [picInfoArray count], picScroll.frame.size.height);
    [self addPictureToScroll];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        picInfoArray = [[NSMutableArray alloc] init];
        picImgViewArray = [[NSMutableArray alloc] init];
        [self initSubviews];
    }
    return self;
}

- (void)setCurrentId: (NSNumber *)number
{
    if (currentId != nil)
    {
        [currentId release];
    }
    
    currentId = [NSNumber numberWithInt: [number intValue]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    isBarAppear = YES;
    [self getPicDataSource];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CMPopTipViewDelegate
- (void)shareByTencentBlog: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
    
    if ([XDManagerTool connectedToNetwork]) 
    {
        NSString *shareContent = [[NSString alloc] initWithFormat: @"%@%@", [[picInfoArray objectAtIndex: currentPic] objectForKey: KPICDETAILNAME], [[picInfoArray objectAtIndex: currentPic] objectForKey: KPICDETAILLINK]];
        NSString *imgUrl = [[XDDataCenter sharedCenter] getCacheImagePath: [[picInfoArray objectAtIndex: currentPic] objectForKey: KPICDETAILURL]];
        [[XDForwardToBlogViewController shareController] shareImageByTencentBlog: self shareContent: shareContent imageUrl:imgUrl];
        [shareContent release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: @"当前网络不给力，请稍后再试！" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)shareBySinaBlog: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }
    
    if ([XDManagerTool connectedToNetwork]) 
    {
        NSString *shareContent = [[NSString alloc] initWithFormat: @"%@%@", [[picInfoArray objectAtIndex: currentPic] objectForKey: KPICDETAILNAME], [[picInfoArray objectAtIndex: currentPic] objectForKey: KPICDETAILLINK]];
        NSString *imgUrl = [[XDDataCenter sharedCenter] getCacheImagePath: [[picInfoArray objectAtIndex: currentPic] objectForKey: KPICDETAILURL]];
        [[XDForwardToBlogViewController shareController] shareBySinaBlog: self shareContent: shareContent shareImage: imgUrl];
        [shareContent release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: @"当前网络不给力，请稍后再试！" delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)shareByMail: (CMPopTipView *)popTipView
{
    if (popShare.isPop)
    {
        [popShare dismissAnimated:YES];
    }

    NSString *imgUrl = [[NSString alloc] initWithString: [[XDDataCenter sharedCenter] getCacheImagePath: [[picInfoArray objectAtIndex: currentPic] valueForKey: KPICDETAILURL]]];
    [[XDManagerTool Instance] emailInViewController: self imgUrl: imgUrl title: [[picInfoArray objectAtIndex: currentPic] valueForKey: KPICDETAILNAME] body: [[picInfoArray objectAtIndex: currentPic] valueForKey: KPICDETAILNAME]];
    [imgUrl release];
}


#pragma mark - UIScrollView Delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //isBarAppear = NO;
    //topBar.hidden = YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    NSString *num = [[NSString alloc] initWithFormat: @"%i", page + 1];
    currentNumLabel.text = num;
    [num release];
}


#pragma mark - private methods

- (void)refreshPicDataSource: (NSArray *)array
{
    if (array != nil && [array count] != 0) 
    {
        [self setPicInfoArray: array];
    }
}

- (void)getPicDataSource
{
    NSArray *result = [[XDDataCenter sharedCenter] getPhotoList: [currentId intValue] onComplete: ^(NSArray *array)
                       {
                           [self refreshPicDataSource: array];
                           
                           return ;
                       }
                                                        onError: ^(NSError *error)
                       {
                           
                       }];
    
    [self refreshPicDataSource: result];
}

- (void)back
{
    XDTabBarController *tabBarController = (XDTabBarController *)self.navigationController.parentViewController;
    tabBarController.customTabBarView.hidden = NO;
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)sharePic
{
    if (popShare == nil)
    {
        popShare = [[CMPopTipView alloc] initWithCustomView: [XDManagerTool initSharePopView: self]];
        popShare.delegate = self;
        popShare.backgroundColor = [UIColor lightGrayColor];
    }
    
    if (!popShare.isPop) 
    {
        popShare.shandowView.frame = self.view.frame;
        [self.view addSubview: popShare.shandowView];
        [popShare presentPointingAtBarButtonItem: [topBar.items objectAtIndex: 4] animated: YES];
        [self.view bringSubviewToFront: popShare];
    }
    else 
    {
        [popShare dismissAnimated:YES];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *info;
    if (error != NULL)  
    {  
        info = @"图片保存失败";  
        
    }  
    else  // No errors  
    {   info = @"图片保存成功";
    }  
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: info message: nil delegate:self cancelButtonTitle: @"确定" otherButtonTitles:nil, nil];
    
    [errorAlert show];
    [errorAlert release];
}

- (BOOL)imageIsExist: (NSString *)aImgUrl
{
    NSMutableArray* tempUrlListArray = [[NSMutableArray alloc] init];    //临时url集合
    
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        
        //just fetching photos
        if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
        {
            NSString *url = [[result defaultRepresentation] filename];
            [tempUrlListArray addObject:url];
            NSLog(@"%@", url);
        }
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock
    libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop)
    {
        if (group != nil)
        {
            [group enumerateAssetsUsingBlock:groupEnumerAtion];
        }
        else
        {
            [tempUrlListArray release];//释放临时url集合
        }
        
    };
    
    
    
    //异步的
    ALAssetsLibrary* assetLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary | ALAssetsGroupSavedPhotos
                                usingBlock:libraryGroupsEnumeration
                              failureBlock:nil];
    
    return YES;
}


- (void)savePicToLocal
{
    int count = [currentNumLabel.text intValue] - 1;
    NSDictionary *dic = [picInfoArray objectAtIndex: count];
    NSString *imgUrl = [[XDDataCenter sharedCenter] getCacheImagePath: [dic valueForKey: KPICDETAILURL]];
    UIImage *image = [UIImage imageWithContentsOfFile: imgUrl];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"图片已保存！" message: nil delegate:self cancelButtonTitle: @"确定" otherButtonTitles:nil, nil];
//        
//        [alert show];
//        [alert release];
//    }
}

- (void)addPictureToScroll
{
    if ([picInfoArray count] != 0)
    {
        for (UIView *obj in [picScroll subviews])
        {
            if ([obj isKindOfClass: [XDPictureInfoView class]])
            {
                [obj removeFromSuperview];
            }
        }
        
        for (int i = 0; i < [picInfoArray count]; i++) 
        {
            NSDictionary *dic = [picInfoArray objectAtIndex: i];
            XDPictureInfoView *picView = [[XDPictureInfoView alloc] initWithFrame: CGRectMake(picScroll.frame.size.width * i, 0, picScroll.frame.size.width, picScroll.frame.size.height)];
            picView.imgView.oid = [dic valueForKey: KPICDETAILURL];
            picView.imgView.url = [NSURL URLWithString: [dic valueForKey: KPICDETAILURL]];
            [[XDDataCenter sharedCenter] managedObject: picView.imgView];
            picView.imgTitle.text = [dic valueForKey: KPICDETAILNAME];
            
            [picScroll addSubview: picView];
            [picView release];
        }
        
        [picScroll setContentOffset: CGPointMake(0, 0)];
    }
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    isBarAppear = !isBarAppear;
    topBar.hidden = !isBarAppear;
}


@end
