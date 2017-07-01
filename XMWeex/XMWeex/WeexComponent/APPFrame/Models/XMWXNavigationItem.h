//
//  @header XMWXNavigationItem.h
//  @abstract <##>
//  @version <##> 2017/5/18
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWXProtocol.h"

//@{@"title":@"xxxxx",@"leftInfo":@[@{@"aciton":@"refresh",@"itemURL":@"http://xxxx.js"}],@"rightInfo":@[@{@"aciton":@"refresh",@"itemURL":@"http://xxxx.js"}],@"clearNavigationBar"}
@interface XMWXNavigationItem : NSObject<XMWXNavigationBarProtocol>

@property (nonatomic,copy) NSString * titleFont;

@property (nonatomic,copy) NSString * statusBarStyle;

+(instancetype)infoWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
