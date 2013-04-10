//
//  XDHotPictureView.m
//  New
//
//  Created by ed on 12-9-6.
//
//

#import "XDHotPictureView.h"
#import "LocalDefine.h"

static int kImageMarge = 15;
static int kBadgeMarge = 11;
static int kBottomMarge = 15;
static NSString *kRahmenPictureName = @"picBg.png";

@interface XDHotPictureView ()
{
    UIImageView *_rahmenView;
}

@end

@implementation XDHotPictureView

@synthesize managedImageView = _managedImageView;
@synthesize badge = _badge;
@synthesize title = _title;

#pragma mark - Class life cycle

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame: frame oid: nil url: nil number: 0];
}

- (XDHotPictureView*)initWithFrame:(CGRect)aFrame oid:(NSString*)aOid url:(NSURL*)aURL number:(NSUInteger)aNumber
{
    self = [super initWithFrame: aFrame];
    if (self) {
        // Initialization code
        _rahmenView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: kRahmenPictureName]];
        _rahmenView.frame = self.bounds;
        [self addSubview: _rahmenView];
        
        _managedImageView = [[HJManagedImageV alloc] initWithFrame:
                             CGRectMake(self.bounds.origin.x+kImageMarge,
                                        self.bounds.origin.x+kImageMarge,
                                        self.bounds.size.width-2*kImageMarge,
                                        self.bounds.size.height-2*kImageMarge)];
        _managedImageView.image = [UIImage imageNamed: KDEFAULTHOTPIC];
        _managedImageView.oid = [[aOid copy] autorelease];
        _managedImageView.url = [[aURL copy] autorelease];
        _managedImageView.backgroundColor = [UIColor clearColor];
        [self addSubview: _managedImageView];
        
        _badge = [CustomBadge customBadgeWithString: [NSString stringWithFormat: @"%u", aNumber]
                                    withStringColor: [UIColor grayColor]
                                     withInsetColor: [UIColor whiteColor]
                                     withBadgeFrame: YES
                                withBadgeFrameColor: [UIColor clearColor]
                                          withScale: 0.6f
                                        withShining: YES];
        _badge.frame = CGRectMake(self.bounds.origin.x+kBadgeMarge,
                                  self.bounds.origin.y+kBadgeMarge,
                                  _badge.frame.size.width,
                                  _badge.frame.size.height);
        _badge.alpha = 1.0f;
        [self addSubview: _badge];
        
        _title = [[UILabel alloc] initWithFrame: CGRectMake(0, self.bounds.size.height - kBottomMarge, self.bounds.size.width, kBottomMarge)];
        _title.text = @"Title";
        _title.backgroundColor = [UIColor clearColor];
        [_title setTextAlignment: UITextAlignmentCenter];
        _title.font = [UIFont systemFontOfSize: [UIFont smallSystemFontSize]];
        [self addSubview: _title];
    }
    return self;
}

- (void)dealloc
{
    [_managedImageView release];
    [_badge release];
    [_rahmenView release];
    
    [super dealloc];
}

#pragma mark - Public methods

- (void)resetViewWithOid:(NSString*)aOid url:(NSURL*)aURL number:(NSUInteger)aNumber
{
    _managedImageView.oid = [[aOid copy] autorelease];
    _managedImageView.url = [[aURL copy] autorelease];
    
    _badge.badgeText = [NSString stringWithFormat: @"%u", aNumber];
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
