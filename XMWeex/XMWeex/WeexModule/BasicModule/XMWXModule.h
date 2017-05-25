//
//  XMWXModule.h
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>
#import "XMWXProtocol.h"
@interface XMWXModule : NSObject<WXModuleProtocol>

-(void)openURL:(NSString * _Nullable)url options:(nonnull NSDictionary<NSString *,id> *)options completionHandler:(WXCallback _Nullable)completion;


/**
 创建导航栏UI
 @param renderInfo  @{@"title":@"xxxxx",@"leftInfo":@[@{@"aciton":@"refresh",@"itemURL":@"http://xxxx.js"}],@"rightInfo":@[@{@"aciton":@"refresh",@"itemURL":@"http://xxxx.js"}]}
 */
-(void)creatNavigationBarUI:(NSDictionary * _Nullable)renderInfo;

@end

