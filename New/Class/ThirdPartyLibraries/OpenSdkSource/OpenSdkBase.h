//
//  OpenSdkBase.h
//  OpenSdkTest
//
//  Created by aine sun on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    resSuccessed = 1,
    resFailled = 2
}CallApiResponse;

@interface OpenSdkBase : NSObject 

/*
 * 返回clientip，即客户端ip
 */
+ (NSString *) getClientIp;

+ (NSString *) getAppKey ;
+ (NSString *) getAppSecret;
+ (NSString *) getRedirectUri;

/*
 * 在返回url中提取指定参数的值
 */
+ (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle;

/*
 * 显示提示框
 */

+ (void) showMessageBox:(NSString*)content;

/*
 * 生成请求url
 */

+ (NSString*)generateURL:(NSString *)baseUrl
                  params:(NSDictionary *)params
              httpMethod:(NSString *)httpMethod;

@end

@interface NSData (OpenBase64)

/*
 * base64编码
 */

- (NSString *) base64EncodedString;

@end

@interface NSString (OpenEncoding)

/*
 * URL Encode
 */

- (NSString *)URLEncodedString;

@end

@interface NSURL (OpenAdditions)

/*
 * 分解请求串为key-value对组成的字典表
 */

+ (NSDictionary *)getQueryDict:(NSString *)queryString;
 
/*
 * 去空格，检查编码后的字符串是否包含http或者https，若没有则加上后返回url
 */

+ (NSURL *)generateUrlWithType:(NSString *)str;
 
@end
