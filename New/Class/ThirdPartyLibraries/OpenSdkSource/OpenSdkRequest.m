//
//  OpenSdkRequest.m
//  OpenSdkTest
//
//  Created by aine sun on 3/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenSdkRequest.h"
#import <stdlib.h>
#import <CommonCrypto/CommonHMAC.h>
#import "OpenSdkBase.h"

@implementation OpenSdkRequest

#pragma mark -
#pragma mark Constants

/*
 * define some Key-value for oauth1.0 authorize
 */
#define OAuthVersion @"1.0"
#define HMACSHA1SignatureType @"HMAC-SHA1"
#define OAuthConsumerKeyKey @"oauth_consumer_key"
#define OAuthVersionKey @"oauth_version"
#define OAuthSignatureMethodKey @"oauth_signature_method"
#define OAuthTimestampKey @"oauth_timestamp"
#define OAuthNonceKey @"oauth_nonce"
#define OAuthTokenKey @"oauth_token"

/*
 * define some key-value for oauth2.a authorize
 */
#define OAuth2Version @"2.a"
#define OAuth2TokenKey @"access_token"
#define OAuth2OpenidKey @"openid"
#define OAuth2ClientipKey @"clientip"
#define OAuth2ScopeKey @"scope"
#define OAuth2ScopeValue @"all"

#pragma mark -
#pragma mark static methods

#pragma -
#pragma mark generate signatureBaseString for oauth1.0

/*
 * 请求参数按KEY的字母顺序排序
 */

static NSInteger sortRequestParams(NSString *key1, NSString *key2, void *params) {
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) { 
		NSMutableDictionary *dict = (NSMutableDictionary *)params;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}

/*
 * HMAC_SHA1签名
 */

static NSData *HMAC_SHA1(NSString *data, NSString *key) {
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}

/*
 * 使用HMAC-SHA1签名算法生成签名值
 */

- (NSString *)generateRequestSignature:(NSURL *)url
						 appSecret:(NSString *)appSecret 
						   accessSecret:(NSString *)accessSecret 
							httpMethod:(NSString *)httpMethod 
							params:(NSMutableDictionary *)params 
						 normalUrl:(NSString **)normalUrl 
                        normalQueryString:(NSString **)normalQueryString {

    if ([url port]) {
		*normalUrl = [NSString stringWithFormat:@"%@:%@//%@%@", [url scheme], [url port], [url host], [url path]];
	} else {
		*normalUrl = [NSString stringWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]];
	}
	
	NSMutableArray *paramsArray = [NSMutableArray array];
	NSArray *sortedKeys = [[params allKeys] sortedArrayUsingFunction:sortRequestParams context:params];
	for (NSString *key in sortedKeys) {
		NSString *value = [params valueForKey:key];
		[paramsArray addObject:[NSString stringWithFormat:@"%@=%@", key, [value URLEncodedString]]];
	}
	*normalQueryString = [paramsArray componentsJoinedByString:@"&"];

	NSString *requestSigBase = [NSString stringWithFormat:@"%@&%@&%@",
                               httpMethod, [*normalUrl URLEncodedString], [*normalQueryString URLEncodedString]];
    	
	NSString *requestSigKey = [NSString stringWithFormat:@"%@&%@", [appSecret URLEncodedString], accessSecret ? [accessSecret URLEncodedString] : @""];
	NSData *hmacSignature = HMAC_SHA1(requestSigBase, requestSigKey);
	NSString *base64Signature = [hmacSignature base64EncodedString];
	return base64Signature;
}

#pragma -
#pragma mark public function for generate oauth1.0 and oauth2.0 request url

/*
 * 格式化请求参数，各项用&符号分隔，生成api接口人request_url的公用函数
 */

- (NSString *)connectParams:(NSMutableDictionary *)params {
	
	NSMutableArray *tmpParamsArray = [NSMutableArray array];
	for (NSString *key in params) {
        
		[tmpParamsArray addObject:[NSString stringWithFormat:@"%@=%@", key, [[params valueForKey:key] URLEncodedString]]];
	}
	return [tmpParamsArray componentsJoinedByString:@"&"];
}

#pragma -
#pragma mark getResponseData, public function for http get and http post method

/*
 * 获取响应结果，即返回数据
 */

- (NSString *)getResponseData:(NSURLRequest *)request retCode:(uint16_t *)retCode {
	
	NSURLResponse *response = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	NSString *retString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	
	NSLog(@"response code:%d string:%@", httpResponse.statusCode, retString);
    if (httpResponse.statusCode == 200) {
        *retCode = resSuccessed;
        NSLog(@"访问接口成功");
        return retString;
    }
	else {
        *retCode = resFailled;
        NSLog(@"访问接口失败，请检查接口访问路径是否正确无误");
        return nil;
    }
}

#pragma -
#pragma mark generage api request url for oauth1.0

/*
 * 生成oauth1 API接口的request url
 */

- (NSString *)getRequestUrl:(NSString *)url
                        httpMethod:(NSString *)httpMethod 
                        appkey:(NSString *)appKey 
                        appSecret:(NSString *)appSecret 
                        accessToken:(NSString *)accessToken 
                        accessSecret:(NSString *)accessSecret 
                        params:(NSMutableDictionary *)params 
                        queryString:(NSString **)queryString {
       
       NSString *tmpParamString = [self connectParams:params];
       NSMutableString *tmpUrlWithParam = [[[NSMutableString alloc] initWithString:url] autorelease];
       if (tmpParamString && ![tmpParamString isEqualToString:@""]) {
           [tmpUrlWithParam appendFormat:@"?%@", tmpParamString];
       }
       
       NSString *tmpEncodedUrl = [tmpUrlWithParam stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
       NSURL *sigUrl = [NSURL generateUrlWithType:tmpEncodedUrl];
        NSString *sigNonce = [NSString stringWithFormat:@"%u", arc4random() % 9999999 + 123456];
       NSLog(@"sigNonce %@\n", sigNonce);
       NSString *sigTimeStamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
       
       NSMutableDictionary *finalParams;
       if (params) {
           finalParams = [[params mutableCopy] autorelease];
       } else {
           finalParams = [NSMutableDictionary dictionary];
       }
    
       [finalParams setObject:sigNonce forKey:OAuthNonceKey];
       [finalParams setObject:sigTimeStamp forKey:OAuthTimestampKey];
       [finalParams setObject:OAuthVersion forKey:OAuthVersionKey];
       [finalParams setObject:HMACSHA1SignatureType forKey:OAuthSignatureMethodKey];
       [finalParams setObject:appKey forKey:OAuthConsumerKeyKey];
       if (accessToken) {
           [finalParams setObject:accessToken forKey:OAuthTokenKey];
       }
       
       NSString *normalUrl = nil;
       NSMutableString *tmpQueryString = nil;
    
       NSString *signatureValue = [self generateRequestSignature:sigUrl 
                                              appSecret:appSecret 
                                                accessSecret:accessSecret 
                                                 httpMethod:httpMethod 
                                                 params:finalParams 
                                                 normalUrl:&normalUrl 
                                                normalQueryString:&tmpQueryString];
       [tmpQueryString appendFormat:@"&oauth_signature=%@", [signatureValue URLEncodedString]];
       *queryString = [[[NSString alloc] initWithString:tmpQueryString] autorelease];
       
       return normalUrl;
}

#pragma -
#pragma mark generate oauth2.0 request url

/*
 * 生成oauth2 API接口的request url
 */
- (NSString *)getOauth2RequestUrl:(NSString *)url
                       httpMethod:(NSString *)httpMethod 
                           appkey:(NSString *)appKey 
                      accessToken:(NSString *)accessToken 
                           openid:(NSString *)openid 
                           params:(NSMutableDictionary *)params 
                      queryString:(NSString **)queryString{
    NSMutableDictionary *tmpParams = [[NSMutableDictionary alloc] init];
    NSLog(@"params count is %d", [params count]);
    [tmpParams setObject:appKey forKey:OAuthConsumerKeyKey];
    [tmpParams setObject:accessToken forKey:OAuth2TokenKey];
    [tmpParams setObject:openid forKey:OAuth2OpenidKey];
    [tmpParams setObject:[OpenSdkBase getClientIp] forKey:OAuth2ClientipKey];
    [tmpParams setObject:OAuth2Version forKey:OAuthVersionKey];
    [tmpParams setObject:OAuth2ScopeValue forKey:OAuth2ScopeKey];
    
    NSString *tmpParamString = [self connectParams:tmpParams];
    [tmpParams release];
    NSLog(@"params connect %@", tmpParamString);
    NSString *tmpUrl = url;
    
    if (tmpParamString && ![tmpParamString isEqualToString:@""]) {
        NSLog(@"enter if %@", tmpUrl);
        tmpUrl = [tmpUrl stringByAppendingFormat:@"?%@", tmpParamString];
        NSLog(@"tmpUrl %@", tmpUrl);
    }
    
    *queryString = [[[NSString alloc] init] autorelease];
    *queryString = [self connectParams:params];
    return tmpUrl;
}

#pragma mark -
#pragma mark send http request function used for oauth1.0 request and oauth2.0 request

/*
 * 发送get请求，并接受返回的数据
 */

- (NSString *)httpGet:(NSString *)url queryString:(NSString *)queryString oauthType:(uint16_t)oauthType retCode:(uint16_t *)retCode {
    
	NSMutableString *requestUrl = [[NSMutableString alloc] initWithString:url];
	if (queryString) {
        NSLog(@"queryString is %@", queryString);
        if (oauthType == InAuth1) {
            
            [requestUrl appendFormat:@"?%@", queryString];
        }
		else
        {
            [requestUrl appendFormat:@"&%@", queryString];
        }
	}
	
    NSLog(@"request url is %@", requestUrl);
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL generateUrlWithType:requestUrl]] autorelease];
	[request setHTTPMethod:@"GET"];
	[request setTimeoutInterval:20.0f];

	[requestUrl release];
    
	return [self getResponseData:request retCode:retCode];
}

/*
 * 发送post请求，并接受返回的数据
 */

- (NSString *)httpPost:(NSString *)url queryString:(NSString *)queryString retCode:(uint16_t *)retCode {
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL generateUrlWithType:url]] autorelease];
    NSLog(@"request url: %@", queryString);
	[request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:20.0f];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
	[request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [self getResponseData:request retCode:retCode];
}

/*
 * 发送http post请求发表带图片微博，并接受返回的数据
 */

- (NSString *)httpPostWithFile:(NSDictionary *)files url:(NSString *)url queryString:(NSString *)queryString retCode:(uint16_t *)retCode {
	NSLog(@"querystring is %@", queryString);
    
	NSMutableURLRequest *imageRequest = [[[NSMutableURLRequest alloc] initWithURL:[NSURL generateUrlWithType:url]] autorelease];
	[imageRequest setHTTPMethod:@"POST"];
	
    NSString *tmpBoundary = [NSString stringWithFormat:@"%u", arc4random() % (9999999 - 123400) + 123400];
    NSString *boundaryVal = [NSString stringWithFormat:@"Boundary-%@", tmpBoundary];
	
	NSData *boundaryBody = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundaryVal] dataUsingEncoding:NSUTF8StringEncoding];
	[imageRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryVal] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *requestBody = [NSMutableData data];
	NSString *paramsTemplate = @"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@";
	
	NSDictionary *Params = [NSURL getQueryDict:queryString];
	for (NSString *key in Params) {
		
		NSString *value = [Params valueForKey:key];
        NSLog(@"key is %@, value is %@", key, value);
		NSString *formItem = [NSString stringWithFormat:paramsTemplate, boundaryVal, key, value];
		[requestBody appendData:[formItem dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[requestBody appendData:boundaryBody];
    
	NSString *fileTemplate = @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: \"application/octet-stream\"\r\n\r\n";
	for (NSString *key in files) {
		
		NSString *imagePath = [files objectForKey:key];
        NSLog(@"filePath ---- %@", imagePath);
        
		NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        NSLog(@"imageData size is:%d", [imageData length]);
        
		NSString *fileItem = [NSString stringWithFormat:fileTemplate, key, [[imagePath componentsSeparatedByString:@"/"] lastObject]];
		[requestBody appendData:[fileItem dataUsingEncoding:NSUTF8StringEncoding]];
		[requestBody appendData:imageData];
		[requestBody appendData:boundaryBody];
	}
    
    [imageRequest setValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-Length"];
	[imageRequest setHTTPBody:requestBody];
    
    NSLog(@"request %@", imageRequest);
    NSLog(@"request url: %@", queryString);
	return [self getResponseData:imageRequest retCode:retCode];
}

#pragma mark -
#pragma mark instance methods

/*
 * 发送API接口请求，并接受返回的数据
 */

- (NSString *)sendApiRequest:(NSString *)url 
                     httpMethod:(NSString *)httpMethod 
                          oauth:(OpenSdkOauth *)oauth
                         params:(NSMutableDictionary *)params 
                          files:(NSDictionary *)files 
                        oauthType:(uint16_t)oauthType 
                        retCode:(uint16_t *)retCode {
	
	if (!url || [url isEqualToString:@""] || !httpMethod || [httpMethod isEqualToString:@""]) {
		return	nil;
	}
	
    NSLog(@"url is %@", url);
    NSString *queryString = nil;
    NSString *oauthUrl  = nil;
    
    if (oauthType == InAuth1) {
        
        if ((oauth.accessToken == (NSString *)[NSNull null]) || (oauth.accessToken.length == 0) ||
            (oauth.accessSecret == (NSString *)[NSNull null]) || (oauth.accessSecret.length == 0)) {
                NSLog(@"授权失败或没有授权");
                [OpenSdkBase showMessageBox:@"授权失败或没有授权，请重新授权"];
                return nil;
        }
        
        oauthUrl = [self getRequestUrl:url 
                                      httpMethod:httpMethod 
                                          appkey:oauth.appKey 
                                       appSecret:oauth.appSecret 
                                     accessToken:oauth.accessToken
                                    accessSecret:oauth.accessSecret 
                                          params:params 
                                     queryString:&queryString];
    }
	else
    { 
        if ((oauth.accessToken == (NSString *)[NSNull null]) || (oauth.accessToken.length == 0) ||
            (oauth.openid == (NSString *)[NSNull null]) || (oauth.openid.length == 0)) {
            NSLog(@"授权失败或没有授权");
            [OpenSdkBase showMessageBox:@"授权失败或没有授权，请重新授权"];
            return nil;
        }
        
        oauthUrl = [self getOauth2RequestUrl:url 
                            httpMethod:httpMethod 
                                appkey:oauth.appKey 
                           accessToken:oauth.accessToken
                                    openid:oauth.openid
                                params:params
                                 queryString:&queryString];
    }
    
    NSLog(@"oauthUrl is %@ httpmethod is %@", oauthUrl, httpMethod);
	
	NSString *retString = nil;
	if ([httpMethod isEqualToString:@"GET"]) {
		retString = [self httpGet:oauthUrl queryString:queryString oauthType:oauthType retCode:retCode];
	} else if (!files || [files count] == 0) {
		retString = [self httpPost:oauthUrl queryString:queryString retCode:retCode];
	} else {
		retString = [self httpPostWithFile:files url:oauthUrl queryString:queryString retCode:retCode];
	}
    
	return retString;
}

@end
