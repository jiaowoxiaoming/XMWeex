//
//  @header XMWXAPPFrameComponte.h
//  @abstract <##>
//  @version <##> 2017/5/17
//  XMWeex
//
//  Created by apple on 2017/5/17.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <WeexSDK/WeexSDK.h>

static NSString * const XMWXAPPFrameComponteTabbarItemsKey = @"tabarItems";

static NSString * const XMWXAPPFrameComponteViewControllerItemsKey = @"viewControllerItems";


@interface XMWXAPPFrameComponte : WXComponent

@property (nonatomic,readonly,strong) __kindof UITabBarController * tabarController;



@end
