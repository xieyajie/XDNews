//
//  XDRefreshTableView.h
//  New
//
//  Created by yajie xie on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kPRStateNormal = 0,
    kPRStatePulling = 1,
    kPRStateLoading = 2,
    kPRStateHitTheEnd = 3
} PRState;

@interface LoadingView : UIView {
    UILabel *_stateLabel;
    UILabel *_dateLabel;
    UIImageView *_arrowView;
    UIActivityIndicatorView *_activityView;
    CALayer *_arrow;
    BOOL _loading;
}
@property (nonatomic,getter = isLoading) BOOL loading;    
@property (nonatomic,getter = isAtTop) BOOL atTop;
@property (nonatomic) PRState state;

- (id)initWithFrame:(CGRect)frame atTop:(BOOL)top;

- (void)updateRefreshDate:(NSDate *)date;

@end

@protocol XDRefreshTableViewDelegate;

@interface XDRefreshTableView : UITableView
<UIScrollViewDelegate>
{
    LoadingView *_headerView;
    LoadingView *_footerView;
    UILabel *_msgLabel;
    BOOL _loading;
    BOOL _isFooterInAction;
    NSInteger _bottomRow;
}

@property (assign,nonatomic) id <XDRefreshTableViewDelegate> pullingDelegate;
@property (nonatomic) BOOL autoScrollToNextPage;
@property (nonatomic) BOOL reachedTheEnd;
@property (nonatomic,getter = isHeaderOnly) BOOL headerOnly;

- (id)initWithFrame:(CGRect)frame pullingDelegate:(id<XDRefreshTableViewDelegate>)aPullingDelegate;

- (void)tableViewDidScroll:(UIScrollView *)scrollView;

- (void)tableViewDidEndDragging:(UIScrollView *)scrollView;

- (void)tableViewDidFinishedLoading;

- (void)tableViewDidFinishedLoadingWithMessage:(NSString *)msg;

- (void)launchRefreshing;

@end


@protocol XDRefreshTableViewDelegate <NSObject>

@required
- (void)pullingTableViewDidStartRefreshing:(XDRefreshTableView *)tableView;

@optional
//Implement this method if headerOnly is false
- (void)pullingTableViewDidStartLoading:(XDRefreshTableView *)tableView;

//Implement the follows to set date you want,Or Ignore them to use current date 
- (NSDate *)pullingTableViewRefreshingFinishedDate;
- (NSDate *)pullingTableViewLoadingFinishedDate;

@end
