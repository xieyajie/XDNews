//
//  XDDataCenter.m
//  New
//
//  Created by ed on 12-9-11.
//
//
#import "XDDataCenter.h"
#import "LocalDefine.h"

static NSString *kLocalAddress = @"http://127.0.0.1:8000";
static NSString *kServerAddress = @"www.xingbox.com.cn";//@"106.186.20.90:8000";
//http://www.xingbox.com.cn/
static NSString *kAPIPath = @"post";

static NSString *kPostTypeAddress = @"post_type_list/";
static NSString *kProductTypeAddress = @"product_type_list/";
static NSString *kRollingAddress = @"rolling_post/post类型/post_type/";
static NSString *kGalleryListAddress = @"gallery_list/页数/page/";
static NSString *kPhotoListAddress = @"photo_list/gallery的id/gallery//";
static NSString *kPostListAddress = @"post_list/post类型/post_type/页数/page/";
static NSString *kProductListAddress = @"product_list/产品类型/product_type/页数/page/";
static NSString *kPostDetailAddress = @"post的id/post_detail/";
static NSString *kPostReplyAddress = @"post的id/post_reply/页数/page/";
static NSString *kSubmitReplyAddress = @"submit_reply/";

static NSString *kPageNumPart = @"页数";
static NSString *kGalleryIdPart = @"gallery的id";
static NSString *kPostTypePart = @"post类型";
static NSString *kProductTypePart = @"产品类型";
static NSString *kPostIdPart = @"post的id";

static NSString *kPostTypesKey = @"post_types";
static NSString *kProductTypesKey = @"product_types";
static NSString *kRollingKey = @"posts";
static NSString *kGalleryListKey = @"galleries";
static NSString *kPhotoListKey = @"photos";
static NSString *kPostListKey = @"posts";
static NSString *kProductListKey = @"posts";
static NSString *kPostReplyKey = @"replies";

static NSString *kReplyIdKey = @"post_id";
static NSString *kReplyContentKey = @"content";
static NSString *kReplyParentIdKey = @"parent";

static NSString *kServerDataFileName = @"server_data.plist";

#define kRequestPhotoListKey @"PhotoListKey"
#define kRequestProductListKey @"RequestProductListKey"
#define kDetailKey @"DetailKey"

@interface XDDataCenter ()
{
    MKNetworkEngine *_netEngine;
    HJObjManager *_objManager;
    
    NSMutableDictionary *_infoCacheDic;
    NSMutableDictionary *_requestDic;
}

- (BOOL)isOfflineMode;

- (void)cancelRequest:(NSString *)aKey;

- (void)requestInfo:(NSString*)aPath andOriginKey:(NSString*)aOriginKey andCacheKey:(NSString*)aCacheKey andRequestKey:(NSString*)aRequestKey onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError;

@end

@implementation XDDataCenter

+ (XDDataCenter *)sharedCenter
{
    static dispatch_once_t once;
    static XDDataCenter *sharedCenter;
    dispatch_once(&once, ^ { sharedCenter = [[XDDataCenter alloc] init]; });
    return sharedCenter;
}

#pragma mark - Class life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _netEngine = [[MKNetworkEngine alloc] initWithHostName: kServerAddress];
        _netEngine.apiPath = kAPIPath;
        
        _objManager = [[HJObjManager alloc] init];
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        HJMOFileCache *fileCache = [[HJMOFileCache alloc] initWithRootPath: cacheDirectory];
        _objManager.fileCache = fileCache;
        [fileCache release];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString *serverDataFilePath = [[_netEngine cacheDirectoryName] stringByAppendingPathComponent: kServerDataFileName];
        if ([fm fileExistsAtPath: serverDataFilePath])
        {
            _infoCacheDic = [[NSMutableDictionary alloc] initWithContentsOfFile: serverDataFilePath];
        }
        else
        {
            [fm createFileAtPath: serverDataFilePath contents: nil attributes: nil];
            _infoCacheDic = [[NSMutableDictionary alloc] init];
            
            [_infoCacheDic writeToFile: serverDataFilePath atomically: YES];
        }
        
        _requestDic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)cacheData
{
    NSString *serverDataFilePath = [[_netEngine cacheDirectoryName] stringByAppendingPathComponent: kServerDataFileName];
    [_infoCacheDic writeToFile: serverDataFilePath atomically: YES];
}

#pragma mark - Public methods

- (NSUInteger)cacheSize
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *readyDirectory = [_netEngine cacheDirectoryName];
    NSString *loadingDirectory = [readyDirectory stringByReplacingOccurrencesOfString: MKNETWORKCACHE_DEFAULT_DIRECTORY withString: @"loading"];
    unsigned long long readySize = [[fm attributesOfItemAtPath: readyDirectory error: nil] fileSize];
    unsigned long long loadingSize = [[fm attributesOfItemAtPath: loadingDirectory error: nil] fileSize];
    
    NSUInteger result = readySize + loadingSize - 136; // 此处假设两个文件夹中没有二级目录，则，两个文件夹所占大小为136；
    
    return result;
}

- (void)cleanCache
{
    [_objManager cancelLoadingObjects];
    [_objManager.fileCache emptyCache];
}

- (void)managedObject:(id<HJMOUser>)aObject
{
    [_objManager performSelectorOnMainThread: @selector(manage:) withObject: aObject waitUntilDone: YES];
}

- (NSArray*)getPostType: (XDCompleteBlock)handleComplete onError: (XDErrorBlock)handleError
{
    if (![self isOfflineMode])
    {
        [self requestInfo: kPostTypeAddress andOriginKey: kPostTypesKey andCacheKey: kPostTypesKey andRequestKey: nil onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: kPostTypesKey];
}

- (NSArray*)getProductType:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    if (![self isOfflineMode])
    {
        [self requestInfo: kProductTypeAddress andOriginKey: kProductTypesKey andCacheKey: kProductTypesKey andRequestKey: nil onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: kProductTypesKey];
}

- (NSArray*)getRolling:(NSUInteger)aPostType onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    if (![self isOfflineMode])
    {
        NSString *postTypeStr = [NSString stringWithFormat: @"%u", aPostType];
        NSString *path = [kRollingAddress stringByReplacingOccurrencesOfString: kPostTypePart withString: postTypeStr];
        NSString *key = [kRollingKey stringByAppendingFormat: @"%@", postTypeStr];
        
        [self requestInfo: path andOriginKey: kRollingKey andCacheKey: key andRequestKey: nil onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: kRollingKey];
}

- (NSArray*)getGalleryList:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(MKNKErrorBlock)handleError
{
    NSString *pageStr = [NSString stringWithFormat: @"%u", aPageNum];
    NSString *path = [kGalleryListAddress stringByReplacingOccurrencesOfString: kPageNumPart withString: pageStr];
    NSString *key = [kGalleryListKey stringByAppendingString: pageStr];
    
    if (![self isOfflineMode])
    {
        [self requestInfo: path andOriginKey: kGalleryListKey andCacheKey: key andRequestKey: nil onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: key];
}

- (NSArray*)getPhotoList:(NSUInteger)aGalleryId onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    [self cancelRequest: kRequestPhotoListKey];
    
    NSString *galleryIdStr = [NSString stringWithFormat: @"%u", aGalleryId];
    NSString *path = [kPhotoListAddress stringByReplacingOccurrencesOfString: kGalleryIdPart withString: galleryIdStr];
    NSString *key = [kPhotoListKey stringByAppendingFormat: @"%@", galleryIdStr];
    
    if (![self isOfflineMode])
    {
        [self requestInfo: path andOriginKey: kPhotoListKey andCacheKey: key andRequestKey: kRequestPhotoListKey onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: key];
}

- (NSArray*)getPostList:(NSUInteger)aPostType andPageNum:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    NSString *postTypeStr = [NSString stringWithFormat: @"%u", aPostType];
    NSString *pageStr = [NSString stringWithFormat: @"%u", aPageNum];
    NSString *path = [[kPostListAddress stringByReplacingOccurrencesOfString: kPageNumPart withString: pageStr] stringByReplacingOccurrencesOfString: kPostTypePart withString: postTypeStr];
    NSString *key = [kPostListKey stringByAppendingFormat: @"%@-%@", postTypeStr, pageStr];
    
    if (![self isOfflineMode])
    {
        [self requestInfo: path andOriginKey: kPostListKey andCacheKey: key andRequestKey: nil onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: key];
}

- (NSArray*)getProductList:(NSUInteger)aProductType andPageNum:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    [self cancelRequest: kRequestProductListKey];
    
    NSString *productTypeStr = [NSString stringWithFormat: @"%u", aProductType];
    NSString *pageStr = [NSString stringWithFormat: @"%u", aPageNum];
    NSString *path = [[kProductListAddress stringByReplacingOccurrencesOfString: kProductTypePart withString: productTypeStr] stringByReplacingOccurrencesOfString: kPageNumPart withString: pageStr];
    NSString *key = [kProductListKey stringByAppendingFormat: @"%@-%@", productTypeStr, pageStr];
    
    if (![self isOfflineMode])
    {
        [self requestInfo: path andOriginKey: kProductListKey andCacheKey: key andRequestKey: kRequestProductListKey onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: key];
}

- (NSDictionary*)getPostDetail:(NSUInteger)aPostId onComplete:(void (^)(NSDictionary *))handleComplete onError:(XDErrorBlock)handleError
{
    [self cancelRequest: kDetailKey];
    
    NSString *postIdStr = [NSString stringWithFormat: @"%u", aPostId];
    NSString *path = [kPostDetailAddress stringByReplacingOccurrencesOfString: kPostIdPart withString: postIdStr];
    NSString *key = [NSString stringWithFormat: @"post-%@", postIdStr];
    
    if (![self isOfflineMode])
    {
        MKNetworkOperation *op= [_netEngine operationWithPath: path];
        
        NSMutableArray *array = [_requestDic objectForKey: kDetailKey];
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            [_requestDic setObject: array forKey: kDetailKey];
            [array addObject: op];
            [array release];
        }
        else{
            [array addObject: op];
        }

        
        [op onCompletion: ^(MKNetworkOperation *operation){
            
            NSLog(@"Get post type Success");
            
            NSDictionary *resultArray;
            
            resultArray = [operation responseJSON];
            
            [_infoCacheDic setObject: resultArray forKey: key];
            
            handleComplete(resultArray);
        }
                 onError: ^(NSError *error){
                     
                     NSLog(@"Get post type Fail");
                     
                     handleError(error);
                 }];
        
        [_netEngine enqueueOperation: op];
    }
    
    return [_infoCacheDic objectForKey: key];
}

- (NSArray*)getPostReply:(NSUInteger)aPostId andPageNum:(NSUInteger)aPageNum onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    NSString *postIdStr = [NSString stringWithFormat: @"%u", aPostId];
    NSString *pageStr = [NSString stringWithFormat: @"%u", aPageNum];
    NSString *path = [[kPostReplyAddress stringByReplacingOccurrencesOfString: kPostIdPart withString: postIdStr] stringByReplacingOccurrencesOfString: kPageNumPart withString: pageStr];
    NSString *key = [kPostReplyKey stringByAppendingFormat: @"%@-%@", postIdStr, pageStr];
    
    if (![self isOfflineMode])
    {
        [self requestInfo: path andOriginKey: kPostReplyKey andCacheKey: key andRequestKey: nil onComplete: handleComplete onError: handleError];
    }
    
    return [_infoCacheDic objectForKey: key];
}

- (void)sendReply:(NSUInteger)aPostId andContent:(NSString*)aContent andParentID:(NSString*)aParentID onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    /*NSString *postIdStr = [NSString stringWithFormat: @"%u", aPostId];
    
    NSString *urlPath = [NSString stringWithFormat: @"http://%@/post/%@?post_id=%@&content=%@&parent=%@", kServerAddress, kSubmitReplyAddress, postIdStr, aContent, aParentID];
    if (0 == aParentID.length)
    {
        urlPath = [urlPath stringByReplacingOccurrencesOfString: @"&parent=" withString: @""];
    }
    MKNetworkOperation *op = [_netEngine operationWithURLString: urlPath];
    
    NSLog(@"%@", op.url);
    [op onCompletion: ^(MKNetworkOperation *operation){
        
        NSLog(@"Send reply Success");
        
        handleComplete(nil);
    }
             onError: ^(NSError *error){
                 
                 NSLog(@"Send reply Fail");
                 
                 handleError(error);
             }];
    
    [_netEngine enqueueOperation: op];*/
    
    NSString *postIdStr = [NSString stringWithFormat: @"%u", aPostId];
    NSMutableDictionary *replyJson = [[NSMutableDictionary alloc] initWithObjectsAndKeys: postIdStr, kReplyIdKey, aContent, kReplyContentKey, nil];
    if (aParentID != nil && aParentID != @"") 
    {
        [replyJson setObject: aParentID forKey: kReplyParentIdKey];
    }
    
    if (![self isOfflineMode])
    {
        MKNetworkOperation *op = [_netEngine operationWithPath: kSubmitReplyAddress params: replyJson httpMethod: @"POST"];
        
        [op onCompletion: ^(MKNetworkOperation *operation){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData: operation.responseData options:kNilOptions error: nil];
            NSLog(@"Send reply Success： %@", json);
            
            handleComplete(nil);
        }
                 onError: ^(NSError *error){
                     
                     NSLog(@"Send reply Fail");
                     
                     handleError(error);
                 }];
        
        [_netEngine enqueueOperation: op];
    }
    
    [replyJson release];
}

- (NSString*)getCacheImagePath:(NSString*)url
{
    NSString *result = [_objManager.fileCache readyFilePathForOid: url];
    if ([[NSFileManager defaultManager] fileExistsAtPath: result])
    {
        return result;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Private methods

- (BOOL)isOfflineMode
{
    NSString *settingPath = [NSHomeDirectory() stringByAppendingPathComponent: KSETTINGPLIST];

    BOOL result = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath: settingPath])
    {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile: settingPath];
        if ([[dic objectForKey: KOFFLINEKEY] boolValue])
        {
            result = YES;
        }
    }
    
    return result;
}

- (void)cancelRequest:(NSString *)aKey
{
    NSArray *array = [_requestDic objectForKey: aKey];
    if (array)
    {
        if (array.count != 0)
        {
            [array makeObjectsPerformSelector: @selector(cancel)];
        }
        [_requestDic removeObjectForKey: aKey];
    }
}

- (void)requestInfo:(NSString*)aPath andOriginKey:(NSString*)aOriginKey andCacheKey:(NSString*)aCacheKey andRequestKey:(NSString*)aRequestKey onComplete:(XDCompleteBlock)handleComplete onError:(XDErrorBlock)handleError
{
    MKNetworkOperation *op= [_netEngine operationWithPath: aPath];
    
    if (aRequestKey != nil)
    {
        NSMutableArray *array = [_requestDic objectForKey: aRequestKey];
        if (array == nil)
        {
            array = [[NSMutableArray alloc] init];
            [_requestDic setObject: array forKey: aRequestKey];
            [array addObject: op];
            [array release];
        }
        else{
            [array addObject: op];
        }
    }
    
    [op onCompletion: ^(MKNetworkOperation *operation){
        
        NSLog(@"Get post type Success");
        
        NSArray *resultArray;
        if (nil != aOriginKey)
        {
            NSDictionary *dic = [operation responseJSON];

            [_infoCacheDic setValue: [dic objectForKey: aOriginKey] forKey: aCacheKey];
            
            resultArray = [dic objectForKey: aOriginKey];
        }
        else
        {
            resultArray = [operation responseJSON];
            
            [_infoCacheDic setValue: resultArray forKey: aCacheKey];
        }
        
        handleComplete(resultArray);
    }
             onError: ^(NSError *error){
                 
                 NSLog(@"Get post type Fail");
                 
                 handleError(error);
             }];
    
    [_netEngine enqueueOperation: op];
}

@end
