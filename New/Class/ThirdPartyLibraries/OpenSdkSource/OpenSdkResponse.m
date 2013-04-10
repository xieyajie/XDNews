//
//  OpenSdkResponse.m
//  OpenSdkTest
//
//  Created by aine sun on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenSdkResponse.h"

@implementation OpenSdkResponse

@synthesize ret = _ret;
@synthesize errcode = _errcode;
@synthesize msg = _msg;
@synthesize responseDict =_responseDict;

#pragma -
#pragma mark parse response data

- (NSInteger)parseData:(NSString *)retString {
    
    NSMutableDictionary *result = [retString objectFromJSONString];
    
    self.ret = [[result objectForKey:@"ret"] intValue];
    if (self.ret != 0) {
        self.errcode = [[result objectForKey:@"errcode"] intValue];
        self.msg = [result objectForKey:@"msg"];
        NSLog(@"调用接口失败");
        return CALLAPI_FAIL;
    }
    
    self.errcode = [[result objectForKey:@"errcode"] intValue];
    self.msg = [result objectForKey:@"msg"];
    id tmpData = [result objectForKey:@"data"];
    
    if ([[NSNull null] isEqual:tmpData]) {
        NSLog(@"没有数据");
        return CALLAPI_NO_DATA;
    }
    else {
        NSLog(@"调用接口成功且有数据");
        self.responseDict = tmpData;
        return CALLAPI_SUCCESSED;
    }
}

- (void)dealloc {
	[_msg release];
	[_responseDict release];
	[super dealloc];
}

@end
