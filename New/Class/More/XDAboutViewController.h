//
//  XDAboutViewController.h
//  New
//
//  Created by dhcdht on 12-9-15.
//
//

#import <UIKit/UIKit.h>

@interface XDAboutViewController : UIViewController
{
    IBOutlet UIWebView *_webView;
    IBOutlet UIImageView *_logoView;
}

- (IBAction)back:(id)sender;

@end
