//
//  XDHotPictureViewController.h
//  New
//
//  Created by dhcdht on 12-9-5.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class XDPictureScanViewController;
@interface XDHotPictureViewController : UIViewController
{
    int currentPage;
    
    XDPictureScanViewController *picScanViewController;
}


@end
