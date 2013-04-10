//
//  LocalDefine.h
//  New
//
//  Created by yajie xie on 12-9-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef New_LocalDefine_h
#define New_LocalDefine_h

#define KSINASHAREURL @"http://v.t.sina.com.cn/share/share.php?"
#define KSINAAPPKEY @"170030983"
#define KSINAAPPSECRET @"6a569af3aeab9553c2f2b4ad7f8d83ba"

#define KTENCENTSHAREURL @"https://open.t.qq.com/api/t/re_add?"
#define KClientIpValue @"106.186.20.90"
#define KTENCENTAPPKEY @"801239289"
#define KTENCENTAPPSECRET @"9223db56197f01a08dbf5481a3378dc0"

/*
 * 获取oauth1.0票据的key
 */
#define oauth1TokenKey @"AccessToken"
#define oauth1SecretKey @"AccessTokenSecret"

/*
 * 获取oauth2.0票据的key
 */
#define oauth2TokenKey @"access_token="
#define oauth2OpenidKey @"openid="
#define oauth2OpenkeyKey @"openkey="
#define oauth2ExpireInKey @"expire_in="

//默认图片
#define KDEFAULTIMGURL @"blueArrow.png"
#define KDEFAULTHOTPIC @"hotPicDefault.png"
#define KDEFAULTPICDETAIL @"picDetailDefault.png"
#define KDEFAULTFOCUSIMG @"focusImageDefault.png"
#define KDEFAULTNEWSCELLIMG @"newsCellDefault.png"

//通知名称
#define KSINASHARELAND @"sinaShareLand"

//首页
#define KLogoViewHeight 40
#define KCustomTabBarHeight 44
#define KTypeScrollViewHeight 30
#define KPictureScrollerViewHeight 130
#define KNewListHeight (460 - KCustomTabBarHeight - KLogoViewHeight - KTypeScrollViewHeight)

//新闻cell高度
#define KNEWSCELLHEIGHT 60

//tableView每次刷新最多获取的行数
#define KREFRESHTABLEMAXCOUNT 10

//资讯下的分类关键字
#define KINFOTYPEID @"id"
#define KINFOTYPENAME @"name"

//资讯页面轮显图片关键字 && 资讯页面cell新闻关键字
#define KINFOCELLID @"post_id"
#define KINFOCELLIMG @"picture"
#define KINFOCELLTITLE @"title"
#define KINFOCELLPREVIEW @"preview"
#define KINFOCELLWEBURL @"post_url"
#define KINFOCELLCOMMENTCOUNT @"reply_count"
//#define KINFOCELLDATE @"pub_date"

//新闻详细信息关键字
#define KDETAILINFOTITLE @"title"
#define KDETAILINFOCONTENT @"content"
#define KDETAILINFODATE @"pub_date"
#define KDETAILINFOCOMMENTCOUNT @"reply_count"

#define KTITLEFONTSIZEMIN @"16"
#define KDATEFONTSIZEMIN @"10"
#define KCONTENTFONTSIZEMIN @"13"
#define KTITLEFONTSIZEMID @"30"
#define KDATEFONTSIZEMID @"12"
#define KCONTENTFONTSIZEMID @"16"
#define KTITLEFONTSIZEMAX @"35"
#define KDATEFONTSIZEMAX @"14"
#define KCONTENTFONTSIZEMAX @"25"

//热图的每个图集关键字
#define KHOTPICID @"id"
#define KHOTPICCOUNT @"photo_count"
#define KHOTPICIMGURL @"sample_url"
#define KHOTPICTITLE @"title"

//热图下的图片关键字
#define KPICDETAILID @"id"
#define KPICDETAILNAME @"name"
#define KPICDETAILURL @"url"
#define KPICDETAILLINK @"link"

//专题每个分类的关键字
#define KTOPICID @"id"
#define KTOPICNAME @"name"

//回复列表的关键字
#define KREPLYCONTENT @"content"
#define KREPLYHEAD @"head"
#define KREPLYPARENTS @"parents"
#define KREPLYPUBDATE @"pub_date"
#define kREPLYID @"reply_id"
#define KREPLYUSER @"user"
#define KREPLYPARENTID @"parent_id"

//我的收藏相关
#define KFAVORITEPATH @"Documents/favorite/"
#define KFAVORITENEWSPLIST @"Documents/favorite/favoriteNews.plist"
#define KFAVORITENEWSIMGCACHE @"Documents/favorite/imgCache/"
#define KFAVORITENEWSID @"id"
#define KFAVORITENEWSIMG @"picture"
#define KFAVORITENEWSTITLE @"title"
#define KFAVORITENEWSBRIEF @"preview"
#define KFAVORITENEWSWEBURL @"post_url"
#define KFAVORITENEWSCONTENT @"content"
#define KFAVORITENEWSDATE @"pub_date"

//设置相关
#define KSETTINGPLIST @"Documents/setting.plist"
#define KFONTSIZEKEY @"fontSize"
#define KNEWSPUSHKEY @"newsPush"
#define KOFFLINEKEY @"offLine"

#endif
