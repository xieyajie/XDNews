//
//  XDAboutViewController.m
//  New
//
//  Created by dhcdht on 12-9-15.
//
//
#import <QuartzCore/QuartzCore.h>
#import "XDAboutViewController.h"

@interface XDAboutViewController ()

@end

@implementation XDAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _logoView.layer.shadowColor = [UIColor blackColor].CGColor;
    _logoView.layer.shadowOffset = CGSizeMake(4, 4);
    _logoView.layer.shadowOpacity = 1.0;
    _logoView.layer.shadowRadius = 4.0;
    
    NSString *aboutPath = [[NSBundle mainBundle] pathForResource: @"about" ofType: @"html"];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *htmlString = [NSString stringWithContentsOfFile: aboutPath usedEncoding: &encoding error: &error];
//    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: aboutPath]];
//    if (error)
//    {
//        NSLog(@"about load html error : %@", error);
//    }
    [_webView loadHTMLString: htmlString baseURL: nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_webView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

@end
