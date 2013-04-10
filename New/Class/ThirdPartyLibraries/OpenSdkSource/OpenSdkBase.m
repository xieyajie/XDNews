//
//  OpenSdkBase.m
//  OpenSdkTest
//
//  Created by aine sun on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenSdkBase.h"

@implementation OpenSdkBase

/*
 * Todo：请正确填写您的客户端ip
 */
#define ClientIpValue @"106.186.20.90"

/*
 * Todo: 请填写您的应用的appkey和appsecret
 */
#define oauthAppKey @"801239289"
#define oauthAppSecret @"9223db56197f01a08dbf5481a3378dc0"

/*
 * Todo：请正确填写您的应用网址，否则将导致授权失败
 */
#define redirect_uri @"http://www.xingbox.com.cn/"

#pragma -
#pragma mark get clientip
+ (NSString *) getClientIp {
    return ClientIpValue;
}

#pragma -
#pragma mark getAppKey

+ (NSString *) getAppKey {
    return oauthAppKey;
}

#pragma -
#pragma mark getAppSecret

+ (NSString *) getAppSecret {
    return oauthAppSecret;
}

#pragma -
#pragma mark getRedirectUri

+ (NSString *) getRedirectUri {
    return redirect_uri;
}

#pragma -
#pragma mark getStringFromUrl

+ (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return str;
}

#pragma -
#pragma mark showMessageBox

+ (void) showMessageBox:(NSString*)content{
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
	alert.tag = 'e';
	[alert show];
	[alert release];
}

#pragma -
#pragma mark generateURL

+ (NSString *)generateURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod 
{
	
	NSURL *parsedUrl = [NSURL URLWithString:baseUrl];
	NSString *queryPrefix = parsedUrl.query ? @"&" : @"?";
	
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [params keyEnumerator]) 
    {
		if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
			||([[params valueForKey:key] isKindOfClass:[NSData class]])) 
        {
			if ([httpMethod isEqualToString:@"GET"]) 
            {
				NSLog(@"can not use GET to upload a file");
			}
			continue;
		}
		
		NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																					  NULL, 
																					  (CFStringRef)[params objectForKey:key],
																					  NULL, 
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																					  kCFStringEncodingUTF8);
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
		[escaped_value release];
	}
	NSString* query = [pairs componentsJoinedByString:@"&"];
	
	return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

@end

@implementation NSData (OpenBase64)

#define CHAR64(c) (index_64[(unsigned char)(c)])

#define BASE64_GETC (length > 0 ? (length--, bytes++, (unsigned int)(bytes[-1])) : (unsigned int)EOF)
#define BASE64_PUTC(c) [buffer appendBytes: &c length: 1]

static char basis_64[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/*
 * 私有方法，用于base64EncodedString方法
 */
static inline void output64Chunk( int c1, int c2, int c3, int pads, NSMutableData * buffer )
{
	char pad = '=';
	BASE64_PUTC(basis_64[c1 >> 2]);
	BASE64_PUTC(basis_64[((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4)]);
	
	switch ( pads )
	{
		case 2:
			BASE64_PUTC(pad);
			BASE64_PUTC(pad);
			break;
			
		case 1:
			BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
			BASE64_PUTC(pad);
			break;
			
		default:
		case 0:
			BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
			BASE64_PUTC(basis_64[c3 & 0x3F]);
			break;
	}
}

- (NSString *) base64EncodedString
{
	NSMutableData * buffer = [NSMutableData data];
	const unsigned char * bytes;
	NSUInteger length;
	unsigned int c1, c2, c3;
	
	bytes = [self bytes];
	length = [self length];
	
	while ( (c1 = BASE64_GETC) != (unsigned int)EOF )
	{
		c2 = BASE64_GETC;
		if ( c2 == (unsigned int)EOF )
		{
			output64Chunk( c1, 0, 0, 2, buffer );
		}
		else
		{
			c3 = BASE64_GETC;
			if ( c3 == (unsigned int)EOF )
				output64Chunk( c1, c2, 0, 1, buffer );
			else
				output64Chunk( c1, c2, c3, 0, buffer );
		}
	}
	
	return ( [[[NSString allocWithZone: [self zone]] initWithData: buffer encoding: NSASCIIStringEncoding] autorelease] );
}

@end

@implementation NSString (OpenEncoding)

- (NSString *)URLEncodedString 
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

@end

@implementation NSURL (OpenAdditions)

#pragma mark -
#pragma mark generateUrlWithType

+ (NSDictionary *)getQueryDict:(NSString *)queryString {
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
	for(NSString *pair in pairs) {
		NSArray *keyValue = [pair componentsSeparatedByString:@"="];
		if([keyValue count] == 2) {
			NSString *key = [keyValue objectAtIndex:0];
			NSString *value = [keyValue objectAtIndex:1];
			value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if(key && value)
				[dict setObject:value forKey:key];
		}
	}
	return [NSDictionary dictionaryWithDictionary:dict];
}

+ (NSURL *)generateUrlWithType:(NSString *)str {
	NSURL *     retUrl;
	NSString *  trimmedStr;
	NSRange     urlTypesRange;
	NSString *  urlType;
	
	assert(str != nil);
	
	retUrl = nil;
	
	trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
		urlTypesRange = [trimmedStr rangeOfString:@"://"];
		
		if (urlTypesRange.location == NSNotFound) {
			retUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
		} else {
			urlType = [trimmedStr substringWithRange:NSMakeRange(0, urlTypesRange.location)];
			assert(urlType != nil);
			
			if ( ([urlType compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
				|| ([urlType compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
				retUrl = [NSURL URLWithString:trimmedStr];
			} else {
                retUrl = nil;
                NSLog(@"error:this is not a url scheme");
			}
		}
	}
	
	return retUrl;
}

@end
