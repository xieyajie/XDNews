//
//  OpenApi.m
//  OpenSdkTest
//
//  Created by aine sun on 3/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenApi.h"
//#import "FeatureListViewController.h"

@implementation OpenApi

#pragma -
#pragma mark base define
/*
 * oauth1和oauth2 Api请求的base url
 */
#define ApiBaseUrl @"http://open.t.qq.com/api/"
#define ApiBaseUrl_For_oauth2 @"https://open.t.qq.com/api/"

/*
 * api接口访问路径及名称
 */
#define TAddSuffix @"t/add"
#define TAddPicSuffix @"t/add_pic"
#define UserInfoSuffix @"user/info"
#define FriendsIdollsSuffic @"friends/idollist"
#define FriendsFansSuffic @"friends/fanslist"

/*
 * http请求方式
 */
#define GetMethod @"GET"
#define PostMethod @"POST"

/*
 * 用于统计应用来源，其中1.2为版本号
 */
#define AppFrom @"ios-sdk1.2"

@synthesize filePathName = _filePathName;
@synthesize retCode = _retCode;

#pragma -
#pragma mark private method

/*
 * 根据ApiBaseUrl和接口名称获取接口访问路径
 */
- (NSString *) getApiBaseUrl:(NSString *)suffix {
    
    NSString *retStringUrl = nil;
    if (_OpenSdkOauth.oauthType == InAuth1) {
       retStringUrl = ApiBaseUrl;
    }
    else
    {
        retStringUrl = ApiBaseUrl_For_oauth2;
    }
    
    return [retStringUrl stringByAppendingString:suffix];
}

/*
 * 接口请求的公共参数，必须携带
 */
- (void) getPublicParams {
    [_publishParams setObject:AppFrom forKey:@"appfrom"];
    NSString *SeqId = [NSString stringWithFormat:@"%u", arc4random() % 9999999 + 123456];
    [_publishParams setObject:SeqId forKey:@"seqid"];
    [_publishParams setObject:[OpenSdkBase getClientIp] forKey:@"clientip"];
}

#pragma -
#pragma mark public function for api module

/*
 * 将发表类接口的通用参数存储到字典表成员_publishParams中
 */
- (void) setPublishParams:(NSString *)weiboContent jing:(NSString *)jing wei:(NSString *)wei format:(NSString *)format clientip:(NSString *)clientip syncflag:(NSString *)syncflag  {
    
	[_publishParams setObject:weiboContent forKey:@"content"];  //要发表的微博内容
    [_publishParams setObject:format forKey:@"format"];  //返回数据格式，json或xml
	[_publishParams setObject:clientip forKey:@"clientip"];  //用户侧真实ip
    [_publishParams setObject:jing forKey:@"jing"];  //精度
    [_publishParams setObject:wei forKey:@"wei"];  //纬度
    [_publishParams setObject:syncflag forKey:@"syncflag"];  //微博同步到空间分享标记（可选，0-同步，1-不同步，默认为0）
}

/*
 * 将关系连类接口的通用参数存储到字典表成员_publishParams中
 */
- (void) setFriendListParams:(NSString *)format reqnum:(NSString *)reqnum startIndex:(NSString *)startIndex mode:(NSString *)mode install:(NSString *)install {
    
    [_publishParams setObject:format forKey:@"format"];  //返回数据格式，json或xml
    [_publishParams setObject:reqnum forKey:@"reqnum"];  //请求个数，1-30个
    [_publishParams setObject:startIndex forKey:@"startindex"];  //起始位置，第一页为0，继续向下翻页填 reqnum*(page-1)
    if ( mode != nil ) {
        [_publishParams setObject:mode forKey:@"mode"];  //获取模式，0-旧模式，1-新模式
    }    
    if ( install != nil ) {
        [_publishParams setObject:install forKey:@"install"];  //过滤安装应用好友（可选），1-获取已安装应用好友，2-获取未安装应用好友
    }
}

#pragma -
#pragma mark init

- (id)initForApi:(NSString*)appKey appSecret:(NSString*)appSecret accessToken:(NSString*)accessToken accessSecret:(NSString*)accessSecret openid:(NSString *)openid oauthType:(uint16_t)oauthType
{
	if (self = [super init])
	{
        _OpenSdkRequest = [[OpenSdkRequest alloc] init];
        _OpenSdkOauth = [[OpenSdkOauth alloc] init];

        _OpenSdkOauth.appKey = [[appKey copy] autorelease];
		_OpenSdkOauth.appSecret = [[appSecret copy] autorelease];
        _OpenSdkOauth.accessToken = [[accessToken copy] autorelease];
        _OpenSdkOauth.accessSecret = [[accessSecret copy] autorelease];
        _OpenSdkOauth.openid = [[openid copy] autorelease];
        _OpenSdkOauth.oauthType = oauthType;
	}
	return self;
}

#pragma mark -
#pragma mark T module

- (void) publishWeibo:(NSString *)weiboContent jing:(NSString *)jing wei:(NSString *)wei format:(NSString *)format clientip:(NSString *)clientip syncflag:(NSString *)syncflag {

    NSString *requestUrl = [self getApiBaseUrl:TAddSuffix];
    
    _publishParams = [NSMutableDictionary dictionary];
    
    [self getPublicParams];
    [self setPublishParams:weiboContent jing:jing wei:wei format:format clientip:clientip syncflag:syncflag];
    
    NSString *resultStr = [_OpenSdkRequest sendApiRequest:requestUrl httpMethod:PostMethod oauth:_OpenSdkOauth params:_publishParams files:nil oauthType:_OpenSdkOauth.oauthType retCode:&_retCode];
    
    if (resultStr == nil) {
        NSLog(@"没有授权或授权失败");
        [OpenSdkBase showMessageBox:@"没有授权或授权失败"];
        return;
    }
    
    if (self.retCode == resSuccessed) {
        //[OpenSdkBase showMessageBox:resultStr]; 
        [OpenSdkBase showMessageBox: @"转发成功"];
    }
    else {
        [OpenSdkBase showMessageBox:@"调用t/add接口失败"];
    }
}

- (void) publishWeiboWithImage:(NSString *)filePath weiboContent:(NSString *)weiboContent jing:(NSString *)jing wei:(NSString *)wei format:(NSString *)format clientip:(NSString *)clientip syncflag:(NSString *)syncflag {
    
    NSString *requestUrl = [self getApiBaseUrl:TAddPicSuffix];
    
    NSMutableDictionary *files = [NSMutableDictionary dictionary];
    [files setObject:filePath forKey:@"pic"];
    
    NSData *imageData = [NSData dataWithContentsOfFile:_filePathName];
    NSLog(@"imageData size in publish:%d", [imageData length]);
    
    _publishParams = [NSMutableDictionary dictionary];
    [self getPublicParams];
    [self setPublishParams:weiboContent jing:jing wei:wei format:format clientip:clientip syncflag:syncflag];

    NSString *resultStr = [_OpenSdkRequest sendApiRequest:requestUrl httpMethod:PostMethod oauth:_OpenSdkOauth params:_publishParams files:files oauthType:_OpenSdkOauth.oauthType retCode:&_retCode];
    
    if (resultStr == nil) {
        NSLog(@"没有授权或授权失败");
        [OpenSdkBase showMessageBox:@"没有授权或授权失败"];
        return;
    }
    
    if (self.retCode == resSuccessed) {
        //[OpenSdkBase showMessageBox:resultStr];
        [OpenSdkBase showMessageBox: @"转发成功"];
    }
    else {
        [OpenSdkBase showMessageBox:@"调用t/add_pic接口失败"];
    }
}

#pragma -
#pragma mark User module

- (void) getUserInfo:(NSString *)format {
    
    NSString *requestUrl = [self getApiBaseUrl:UserInfoSuffix];
    
    _publishParams = [NSMutableDictionary dictionary];
    
    [_publishParams setObject:format forKey:@"format"];
    [self getPublicParams];
    
    NSString *resultStr = [_OpenSdkRequest sendApiRequest:requestUrl httpMethod:GetMethod oauth:_OpenSdkOauth params:_publishParams files:nil oauthType:_OpenSdkOauth.oauthType retCode:&_retCode];
    
    if (resultStr == nil) {
        NSLog(@"没有授权或授权失败");
        [OpenSdkBase showMessageBox:@"没有授权或授权失败"];
        return;
    }
    
    if (self.retCode == resSuccessed) {
        _OpenSdkResponse = [[OpenSdkResponse alloc] init];
        NSInteger ret = [_OpenSdkResponse parseData:resultStr];  //解析json数据
        if (ret == 2) {

            if (_OpenSdkResponse.ret == 3 && _OpenSdkResponse.errcode == 1) {
                [OpenSdkBase showMessageBox:resultStr];
                [OpenSdkBase showMessageBox:@"用户授权已失效，需要重新授权"];
            }
        }

        //[OpenSdkBase showMessageBox:resultStr]; 
        [OpenSdkBase showMessageBox: @"转发成功"];
    }
    else {
        [OpenSdkBase showMessageBox:@"调用user/info接口失败"];
    }
}

#pragma -
#pragma mark Friends module

/*
 * 私有函数，解析idollist接口的返回数据，获得并输出具体字段的值 
 */
 
- (NSInteger) parseMyIdollist:(NSString *)resultStr {

    _OpenSdkResponse = [[OpenSdkResponse alloc] init];
    NSInteger ret = [_OpenSdkResponse parseData:resultStr];  //解析json数据

    if (ret == 0) {

        NSInteger hasnext = [[_OpenSdkResponse.responseDict objectForKey:@"hasnext"] intValue];  //获取hasnext值，0－还有数据，1－没有数据
        NSInteger curNum = [[_OpenSdkResponse.responseDict objectForKey:@"curnum"] intValue];  //当前页获取到的数目
        NSLog(@"hasnext is %d, curNum is %d", hasnext, curNum);
    
        NSArray *info = [_OpenSdkResponse.responseDict objectForKey:@"info"];
        NSInteger arrayCnt = [info count];
        NSInteger i = 0;
        while(arrayCnt > i)
        {
            NSMutableDictionary *tmpInfo = [info objectAtIndex:i];
            NSString *name = [tmpInfo objectForKey:@"name"];  //微博帐号
            NSString *openid = [tmpInfo objectForKey:@"openid"];  
            NSString *nick = [tmpInfo objectForKey:@"nick"];  //微博昵称
            NSLog(@"name is %@, openid is %@, nick is %@", name, openid, nick);
            i++;
        }
        return hasnext;
    }
    NSLog(@"ret 不等于 0,call error or no data");
    return -1;//请求失败或没有数据
}

- (void) getMyIdollist:(NSString *)format reqnum:(NSString *)reqnum startIndex:(NSString *)startIndex install:(NSString *)install pageCount:(NSInteger)pageCount {
    
    NSString *resultStr = [[[NSString alloc] init] autorelease];
    
    NSInteger hasnext = 0; //hasnext:0-have more data,1-no more data
//    NSInteger startindex = 0; //值为reqnum * (page - 1)
//    NSString *index = @"0";
//    NSInteger iReqnum = [reqnum intValue] ;  //每页请求个数
    NSInteger page = 1; //页码，用于循环拉取控制页数
    NSInteger successCnt = 0;
    
    //请求多页数据
    do {
        
//        startindex = iReqnum * (page -1);  //下一页请求起始位置
        
        NSString *requestUrl = [self getApiBaseUrl:FriendsIdollsSuffic];
        
        _publishParams = [NSMutableDictionary dictionary];
        [self getPublicParams];
        [self setFriendListParams:format reqnum:reqnum startIndex:startIndex mode:nil install:install];
        
        NSString *resultTmp = [_OpenSdkRequest sendApiRequest:requestUrl httpMethod:GetMethod oauth:_OpenSdkOauth params:_publishParams files:nil oauthType:_OpenSdkOauth.oauthType retCode:&_retCode];
        
        if (resultTmp == nil) {
            NSLog(@"没有授权或授权失败");
            [OpenSdkBase showMessageBox:@"没有授权或授权失败"];
            return;
        }
        
        if (self.retCode == resFailled) {
            successCnt -= 1;
            continue;
        }
        
        successCnt += 1;
        resultStr = [resultStr stringByAppendingString:resultTmp];
        
        NSLog(@"resultStr is %@", resultStr);
        hasnext = [self parseMyIdollist:resultTmp];  //解析json数据，并返回hasnext的值
        if (hasnext == -1) {
            NSLog(@"call api failed or no more data");  //调用失败或没有数据时都不必进行json数据解析
            break;
        }
        
        page += 1;
//        index = [NSString stringWithFormat:@"%d", startindex];
        
    } while (hasnext == 1 && page < pageCount); //请求页数限制，这里只取两页数据
    
    if (successCnt > 0) {
        [OpenSdkBase showMessageBox:resultStr];
    }
    else {
        [OpenSdkBase showMessageBox:@"调用friends/idollist接口失败"];
    }
}

- (void) getMyFanslist:(NSString *)format reqnum:(NSString *)reqnum startIndex:(NSString *)startIndex mode:(NSString *)mode install:(NSString *)install {
    NSString *requestUrl = [self getApiBaseUrl:FriendsFansSuffic];
    
    _publishParams = [NSMutableDictionary dictionary];
    [self getPublicParams];
    [self setFriendListParams:format reqnum:reqnum startIndex:startIndex mode:mode install:install]; 
    
    NSString *resultStr = [_OpenSdkRequest sendApiRequest:requestUrl httpMethod:GetMethod oauth:_OpenSdkOauth params:_publishParams files:nil oauthType:_OpenSdkOauth.oauthType retCode:&_retCode];
    
    if (resultStr == nil) {
        NSLog(@"没有授权或授权失败");
        [OpenSdkBase showMessageBox:@"没有授权或授权失败"];
        return;
    }
    
    if (self.retCode == resSuccessed) {
        [OpenSdkBase showMessageBox:resultStr]; 
    }
    else {
        [OpenSdkBase showMessageBox:@"调用friends/fanslist接口失败"];
    }
}

#pragma -
#pragma viewController function

- (void)loadView {
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//__conn = new CIMCommonConnection() ;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	
	//delete __conn ;
}


- (void)dealloc {
    
    [_OpenSdkOauth release];
    [_OpenSdkRequest release];
    [_publishParams release];
    [_filePathName release];
    [super dealloc];
}

@end
