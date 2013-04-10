//
//  OpenSdkResponse.h
//  OpenSdkTest
//
//  Created by aine sun on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"

enum REPONSE_RESULT {
	CALLAPI_SUCCESSED = 0,
    CALLAPI_NO_DATA = 1,
	CALLAPI_FAIL = 2,
};

@interface OpenSdkResponse : NSObject {
    NSInteger _ret;
    NSInteger _errcode;
    NSString *_msg;
    NSMutableDictionary *responseDict;
}

@property(nonatomic) NSInteger ret;
@property(nonatomic) NSInteger errcode;
@property(nonatomic, retain) NSString *msg;
@property(nonatomic, retain) NSMutableDictionary *responseDict;

/*
 * 解析API接口返回的json数据
 */

- (NSInteger)parseData:(NSString *)retString;

@end
