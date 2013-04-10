//
//  XDDataCenter.h
//  New
//
//  Created by ed on 12-9-11.
//
//

#import <Foundation/Foundation.h>
#import "MKNetworkKit.h"
#import "HJObjManager.h"

typedef void (^XDCompleteBlock)(NSArray *);
typedef MKNKErrorBlock XDErrorBlock;

@interface XDDataCenter : NSObject

+ (XDDataCenter*)sharedCenter;

- (NSUInteger)cacheSize;
- (void)cacheData;
- (void)cleanCache;

- (void)managedObject:(id<HJMOUser>)aObject;

- (NSArray*)getPostType: (XDCompleteBlock)handleComplete onError: (XDErrorBlock)handleError;

- (NSArray*)getProductType:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSArray*)getRolling:(NSUInteger)aPostType onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSArray*)getGalleryList:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSArray*)getPhotoList:(NSUInteger)aGalleryId onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSArray*)getPostList:(NSUInteger)aPostType andPageNum:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSArray*)getProductList:(NSUInteger)aProductType andPageNum:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSDictionary*)getPostDetail:(NSUInteger)aPostId onComplete:(void (^)(NSDictionary*))handleComplete onError:(XDErrorBlock)handleError;

- (NSArray*)getPostReply:(NSUInteger)aPostId andPageNum:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (void)sendReply:(NSUInteger)aPostId andContent:(NSString*)aContent andParentID:(NSString*)aParentID onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

- (NSString*)getCacheImagePath:(NSString*)url;

@end
